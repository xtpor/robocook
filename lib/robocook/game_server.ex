defmodule Robocook.GameServer do
  use GenServer
  alias Robocook.{Game, Level}

  def start_game(players, level_ref) do
  end

  def start_link(players, level_ref) do
    GenServer.start_link(__MODULE__, {players, level_ref})
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

  def update_code(server, robot, ast) do
    GenServer.cast(server, {:update_code, robot, ast})
  end

  def change_speed(server, speed) do
    GenServer.cast(server, {:change_speed, speed})
  end

  def send_text(server, player_name, text) do
    GenServer.cast(server, {:send_text, player_name, text})
  end

  def send_emoji(server, player_name, emoji) do
    GenServer.cast(server, {:send_emoji, player_name, emoji})
  end

  @impl true
  def init({players, level_ref}) do
    level = Robocook.Resource.get!(level_ref)

    {:ok,
     %{
       level: level,
       players: players,
       asts: List.duplicate(empty_ast(), length(players)),
       game: nil,
       speed: :normal,
       status: :editing,
       timer: nil
     }}
  end

  @impl true
  def handle_cast(:play_scene, s = %{status: :editing}) do
    game = Level.pick_scenario(s.level, s.asts)
    notify_all(s, {:status_changed, :playing})
    {:noreply, %{s | game: game, status: :playing, timer: start_timer(s.speed)}}
  end

  def handle_cast(:play_scene, state = %{status: :paused}) do
    notify_all(state, {:status_changed, :playing})
    {:noreply, %{state | status: :playing, timer: start_timer(state.speed)}}
  end

  def handle_cast(:play_scene, state) do
    {:noreply, state}
  end

  def handle_cast(:pause_scene, state = %{status: :playing}) do
    cancel_timer(state.timer)
    notify_all(state, {:status_changed, :paused})
    {:noreply, %{state | status: :playing, timer: nil}}
  end

  def handle_cast(:pause_scene, state) do
    {:noreply, state}
  end

  def handle_cast(:stop_scene, state = %{status: :playing}) do
    cancel_timer(state.timer)
    notify_all(state, {:status_changed, :editing})
    {:noreply, %{state | status: :editing, game: nil, timer: nil}}
  end

  def handle_cast(:stop_scene, state = %{status: :paused}) do
    cancel_timer(state.timer)
    notify_all(state, {:status_changed, :editing})
    {:noreply, %{state | status: :editing, game: nil, timer: nil}}
  end

  def handle_cast(:stop_scene, state) do
    {:noreply, state}
  end

  def handle_cast({:update_code, robot, ast}, state) do
    if state.status == :editing do
      notify_all(state, {:code_changed, robot, ast})
      {:noreply, Map.update!(state, :asts, &replace_ast(&1, robot, ast))}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:change_speed, speed}, state) do
    notify_all(state, {:speed_changed, speed})
    {:noreply, %{state | speed: speed}}
  end

  def handle_cast({:send_text, player_name, text}, state) do
    notify_all(state, {:text_sent, player_name, text})
    {:noreply, state}
  end

  def handle_cast({:send_emoji, player_name, emoji}, state) do
    notify_all(state, {:emoji_sent, player_name, emoji})
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, state) do
    case Game.simulate_tick(state.game) do
      {:tick, t, events, new_game} ->
        notify_all(state, {:game_tick, t, events})
        {:noreply, %{state | game: new_game}}

      {:end, result = {:complete, _}} ->
        notify_all(state, {:game_result, result})
        {:stop, :normal, %{state | status: :completed}}

      {:end, result} ->
        notify_all(state, {:game_result, result})
        cancel_timer(state.timer)
        {:noreply, %{state | status: :editing, game: nil, timer: nil}}
    end
  end

  def notify_all(%{players: players}, msg) do
    Enum.each(players, fn {pid, _name} -> send(pid, msg) end)
  end

  defp start_timer(speed) do
    Process.send_after(self(), :tick, interval(speed))
  end

  def cancel_timer(state) do
    Process.cancel_timer(state.timer)
    flush_timer()
  end

  def flush_timer() do
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

  def replace_ast([_ | rest], 0, ast), do: [ast | rest]
  def replace_ast([head | rest], n, ast), do: [head | replace_ast(rest, n - 1, ast)]

  defp empty_ast do
    [
      {:procedure, 0, []}
    ]
  end
end
