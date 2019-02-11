defmodule Robocook.Room do
  use GenServer
  require Logger

  def start_link(opts) do
    owner_name = Keyword.fetch!(opts, :owner_name)
    owner_pid = Keyword.fetch!(opts, :owner_pid)
    level_ref = Keyword.fetch!(opts, :ref)

    GenServer.start_link(__MODULE__, {owner_pid, owner_name, level_ref})
  end

  def create(level_ref, owner_pid, owner_name) do
    DynamicSupervisor.start_child(
      Robocook.RoomSupervisor,
      {__MODULE__, owner_pid: owner_pid, owner_name: owner_name, ref: level_ref}
    )
  end

  def get_status(room_pid) do
    GenServer.call(room_pid, :get_status)
  end

  def join(room_pid, player_pid, player_name) do
    GenServer.call(room_pid, {:join, player_pid, player_name})
  end

  def leave(room_pid, player_pid) do
    GenServer.cast(room_pid, {:leave, player_pid})
  end

  def kick(room_pid, player_name) do
    GenServer.cast(room_pid, {:kick, player_name})
  end

  def start_game(room_pid) do
    GenServer.cast(room_pid, :start_game)
  end

  @impl true
  def init({owner_pid, owner_name, level_ref}) do
    level = Robocook.Resource.get!(level_ref)
    num_players = level.num_players

    # TODO: handle the this error
    Process.monitor(owner_pid)
    {:ok, id} = Robocook.RoomRegistry.register()
    {:ok, %{players: [{owner_pid, owner_name} | List.duplicate(nil, num_players - 1)], level: level, id: id}}
  end

  @impl true
  def handle_call(:get_status, _from, state) do
    %{id: id, level: level, players: players} = state
    [{_pid, owner_name} | _] = players

    {:reply,
     %{
       id: id,
       title: level.title,
       description: level.description,
       size: size(players),
       capacity: length(players),
       owner: owner_name
     }, state}
  end

  @impl true
  def handle_call({:join, pid, user}, _from, state) do
    %{players: players} = state

    case add_player(players, {pid, user}) do
      {:ok, new_players} ->
        Process.monitor(pid)
        notify_players(players, {:joined, user})

        notification =
          Enum.map(new_players, fn
            {_pid, user} -> user
            nil -> nil
          end)

        {:reply, {:ok, notification}, %{state | players: new_players}}

      :error ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_cast({:leave, pid}, state) do
    {:ok, name} = lookup(state.players, pid)
    handle_player_leave(state, name)
  end

  @impl true
  def handle_cast({:kick, name}, state) do
    %{players: players} = state

    case has_player?(players, name) do
      true ->
        notify_players(players, {:kicked, name})
        {:noreply, %{state | players: remove_player(players, name)}}

      false ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast(:start_game, state) do
    if all_occupied?(state.players) do
      # TODO: spawn the game server
      Logger.info("The game will start shortly")
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    case lookup(state.players, pid) do
      {:ok, name} -> handle_player_leave(state, name)
      :error -> {:noreply, state}
    end
  end

  defp handle_player_leave(state, name) do
    %{players: players} = state
    [{_, owner_name} | _] = players
    new_players = remove_player(players, name)

    if name == owner_name do
      notify_players(players, {:left, name})
      notify_players(new_players, :dismissed)
      {:stop, :normal, %{state | players: new_players}}
    else
      notify_players(players, {:left, name})
      {:noreply, %{state | players: remove_player(players, name)}}
    end
  end

  defp notify_players(players, msg) do
    Enum.each(players, fn
      {pid, _name} -> send(pid, msg)
      nil -> nil
    end)
  end

  def add_player([], _entry) do
    :error
  end

  def add_player([nil | rest], entry) do
    {:ok, [entry | rest]}
  end

  def add_player([p | rest], entry) do
    case add_player(rest, entry) do
      {:ok, new_rest} -> {:ok, [p | new_rest]}
      :error -> :error
    end
  end

  def remove_player([{_pid, name} | rest], name) do
    rest ++ [nil]
  end

  def remove_player([head | rest], pid) do
    [head | remove_player(rest, pid)]
  end

  def lookup([{pid, name} | _players], pid), do: {:ok, name}
  def lookup([_head | rest], pid), do: lookup(rest, pid)
  def lookup([], _pid), do: :error

  def has_player?([{_pid, name} | _], name), do: true
  def has_player?([_ | rest], name), do: has_player?(rest, name)
  def has_player?([], _name), do: false

  def size(players), do: Enum.filter(players, &(&1 != nil)) |> length

  def all_occupied?(players) do
    Enum.all?(players, &(&1 != nil))
  end
end
