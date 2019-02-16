defmodule Robocook.GameServer do
  use GenServer
  alias Robocook.{Game, Level, Players}

  @sup Robocook.GameServerSupervisor

  def start_game(players, level_ref) do
    DynamicSupervisor.start_child(@sup, {__MODULE__, players: players, ref: level_ref})
  end

  def start_link(opts) do
    players = Keyword.fetch!(opts, :players)
    level_ref = Keyword.fetch!(opts, :ref)
    GenServer.start_link(__MODULE__, {players, level_ref})
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :temporary
    }
  end

  def play_scene(server) do
    GenServer.cast(server, :play_scene)
  end

  def pause_scene(server) do
    GenServer.cast(server, :pause_scene)
  end

  def stop_scene(server) do
    GenServer.cast(server, :stop_scene)
  end

  def update_code(server, robot, ast, pid \\ self()) do
    GenServer.cast(server, {:update_code, robot, ast, pid})
  end

  def change_speed(server, speed) do
    GenServer.cast(server, {:change_speed, speed})
  end

  def send_text(server, text, from_pid \\ self()) do
    GenServer.cast(server, {:send_text, from_pid, text})
  end

  def send_emoji(server, emoji, from_pid \\ self()) do
    GenServer.cast(server, {:send_emoji, from_pid, emoji})
  end

  @impl true
  def init({players, level_ref}) do
    level = Robocook.Resource.get!(level_ref)

    Players.monitor(players)
    Players.notify_each(players, fn i -> {:game_started, self(), level_ref, i} end)

    {:ok,
     %{
       level: level,
       players: players,
       asts: Level.generate_initial_asts(level),
       game: nil,
       speed: :normal,
       status: :editing,
       timer: nil
     }}
  end

  @impl true
  def handle_cast(:play_scene, s = %{status: :editing}) do
    {game, index} = Level.pick_scenario(s.level, s.asts)
    Players.notify_all(s.players, {:scene_played, index})
    {:noreply, %{s | game: game, status: :playing, timer: start_timer(s.speed)}}
  end

  @impl true
  def handle_cast(:play_scene, state = %{status: :paused}) do
    Players.notify_all(state.players, :scene_resumed)
    {:noreply, %{state | status: :playing, timer: start_timer(state.speed)}}
  end

  @impl true
  def handle_cast(:play_scene, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast(:pause_scene, state = %{status: :playing}) do
    cancel_timer(state.timer)
    Players.notify_all(state.players, :scene_paused)
    {:noreply, %{state | status: :paused, timer: nil}}
  end

  @impl true
  def handle_cast(:pause_scene, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast(:stop_scene, state = %{status: :playing}) do
    cancel_timer(state.timer)
    Players.notify_all(state.players, :scene_stopped)
    {:noreply, %{state | status: :editing, game: nil, timer: nil}}
  end

  @impl true
  def handle_cast(:stop_scene, state = %{status: :paused}) do
    cancel_timer(state.timer)
    Players.notify_all(state.players, :scene_stopped)
    {:noreply, %{state | status: :editing, game: nil, timer: nil}}
  end

  @impl true
  def handle_cast(:stop_scene, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:update_code, no, ast, pid}, state = %{status: :editing}) do
    controlling_player_no = Enum.at(state.level.robot_controls, no)

    {:ok, player_name} = Players.lookup(state.players, pid)
    case Players.at(state.players, controlling_player_no) do
      {:ok, c_player_name} ->
        if player_name == c_player_name do
          Players.notify_all(state.players, {:code_changed, no, ast})
          {:noreply, Map.update!(state, :asts, &replace_ast(&1, no, ast))}
        else
          {:noreply, state}
        end

      :error ->
        {:ok, owner_name} = Players.at(state.players, 0)
        if player_name == owner_name do
          Players.notify_all(state.players, {:code_changed, no, ast})
          {:noreply, Map.update!(state, :asts, &replace_ast(&1, no, ast))}
        else
          {:noreply, state}
        end
    end
  end

  @impl true
  def handle_cast({:update_code, _, _, _}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:change_speed, speed}, state) do
    Players.notify_all(state.players, {:speed_changed, speed})
    {:noreply, %{state | speed: speed}}
  end

  @impl true
  def handle_cast({:send_text, pid, text}, state) do
    {:ok, name} = Players.lookup(state.players, pid)
    Players.notify_all(state.players, {:text_sent, name, text})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:send_emoji, pid, emoji}, state) do
    {:ok, name} = Players.lookup(state.players, pid)
    Players.notify_all(state.players, {:emoji_sent, name, emoji})
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, state) do
    case Game.simulate_tick(state.game) do
      {:tick, t, events, new_game} ->
        Players.notify_all(state.players, {:game_tick, t, events})
        {:noreply, %{state | game: new_game, timer: start_timer(state.speed)}}

      {:end, result = {:complete, _}} ->
        Players.notify_all(state.players, {:game_result, :success, result})
        {:stop, :normal, %{state | status: :completed}}

      {:end, result} ->
        Players.notify_all(state.players, :scene_stopped)
        Players.notify_all(state.players, {:game_result, :failed, result})
        cancel_timer(state.timer)
        {:noreply, %{state | status: :editing, game: nil, timer: nil}}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    %{players: players} = state
    {:ok, master_player} = Players.at(players, 0)
    case Players.lookup(players, pid) do
      {:ok, name} ->
        Players.notify_all(players, {:game_left, name})
        if name == master_player do
          Players.notify_all(players, :game_aborted)
          {:stop, :normal, state}
        else
          {:noreply, Map.update!(state, :players, &Players.delete(&1, name))}
        end

      :error ->
        {:noreply, state}
    end
  end

  defp start_timer(speed) do
    Process.send_after(self(), :tick, interval(speed))
  end

  defp cancel_timer(timer) do
    Process.cancel_timer(timer)
    flush_timer()
  end

  defp flush_timer() do
    receive do
      :tick -> flush_timer()
    after
      0 -> :ok
    end
  end

  defp interval(:slow), do: 2000
  defp interval(:normal), do: 1000
  defp interval(:fast), do: 500
  defp interval(:very_fast), do: 250

  defp replace_ast([_ | rest], 0, ast), do: [ast | rest]
  defp replace_ast([head | rest], n, ast), do: [head | replace_ast(rest, n - 1, ast)]
end
