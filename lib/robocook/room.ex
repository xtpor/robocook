defmodule Robocook.Room do
  use GenServer
  alias Robocook.Players
  require Logger

  def create(level_ref, owner_pid, owner_name) do
    DynamicSupervisor.start_child(
      Robocook.RoomSupervisor,
      {__MODULE__, owner_pid: owner_pid, owner_name: owner_name, ref: level_ref}
    )
  end

  def start_link(opts) do
    owner_name = Keyword.fetch!(opts, :owner_name)
    owner_pid = Keyword.fetch!(opts, :owner_pid)
    level_ref = Keyword.fetch!(opts, :ref)

    GenServer.start_link(__MODULE__, {owner_pid, owner_name, level_ref})
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :temporary
    }
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

    {:ok,
     %{
       players: [{owner_pid, owner_name} | List.duplicate(nil, num_players - 1)],
       level: level,
       id: id
     }}
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
       size: Players.size(players),
       capacity: Players.capacity(players),
       owner: owner_name
     }, state}
  end

  @impl true
  def handle_call({:join, pid, user}, _from, state) do
    %{players: players} = state

    case Players.add(players, {pid, user}) do
      {:ok, new_players} ->
        Process.monitor(pid)
        Players.notify_all(players, {:joined, user})

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
    {:ok, name} = Players.lookup(state.players, pid)
    handle_player_leave(state, name)
  end

  @impl true
  def handle_cast({:kick, name}, state) do
    %{players: players} = state

    case Players.has?(players, name) do
      true ->
        Players.notify_all(players, {:kicked, name})
        {:noreply, %{state | players: Players.remove(players, name)}}

      false ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast(:start_game, state) do
    if Players.full?(state.players) do
      Robocook.GameServer.start_game(state.players, state.level.ref)
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    case Players.lookup(state.players, pid) do
      {:ok, name} -> handle_player_leave(state, name)
      :error -> {:noreply, state}
    end
  end

  defp handle_player_leave(state, name) do
    %{players: players} = state
    [{_, owner_name} | _] = players
    new_players = Players.remove(players, name)

    if name == owner_name do
      Players.notify_all(players, {:left, name})
      Players.notify_all(new_players, :dismissed)
      {:stop, :normal, %{state | players: new_players}}
    else
      Players.notify_all(players, {:left, name})
      {:noreply, %{state | players: Players.remove(players, name)}}
    end
  end
end
