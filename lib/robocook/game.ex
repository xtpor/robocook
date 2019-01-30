defmodule Robocook.Game do
  alias Robocook.{LevelMap, Ast, Interpreter, GameRule}
  alias Robocook.Game.Goal

  @tick_limit 300

  def new(params) do
    asts = Keyword.fetch!(params, :asts) |> List.to_tuple()

    game = %{
      tick: 0,
      goal: Keyword.fetch!(params, :goal) |> Goal.new(),
      rules: Keyword.fetch!(params, :rules) |> GameRule.new(),
      asts: asts,
      interpreters: build_interpreters(asts),
      levelmap: Keyword.fetch!(params, :levelmap) |> LevelMap.from_ext(),
      status: nil
    }

    update_game_status(game)
  end

  def simulate_tick(game) do
    if all_robots_terminated?(game) || goal_settled?(game) || game.tick >= @tick_limit do
      {:end, game.status}
    else
      tick = game.tick
      {game, robot_logs} = simulate_all_robots(game)
      {game, map_logs} = update_level_map(game)
      game = update_game_status(game)
      game = Map.update!(game, :tick, &(&1 + 1))
      {:tick, tick, robot_logs ++ map_logs, game}
    end
  end

  def simulate_result(game) do
    case simulate_tick(game) do
      {:tick, _tick, _logs, new_game} ->
        simulate_result(new_game)

      {:end, result} ->
        result
    end
  end

  defp simulate_all_robots(game) do
    {game, logs} =
      0..(tuple_size(game.interpreters) - 1)
      |> Enum.reduce({game, []}, fn no, {game, logs} ->
        case robot_step_tick(game, no) do
          {:action, action, game} ->
            case LevelMap.perform_action(game.levelmap, action, no, game.rules) do
              {:ok, log, levelmap} ->
                {%{game | levelmap: levelmap}, [{:action, no, log} | logs]}

              :error ->
                {game, [{:action_error, no, action} | logs]}
            end

          {:error, error, game} ->
            {game, [{:robot_error, no, error} | logs]}
        end
      end)

    {game, Enum.reverse(logs)}
  end

  defp update_level_map(game) do
    {sx, sy} = LevelMap.size(game.levelmap)

    {lmap, inv_logs} =
      for i <- 0..(sx - 1), j <- 0..(sy - 1) do
        {i, j}
      end
      |> Enum.reduce({game.levelmap, []}, fn pos, {lm, logs} ->
        case LevelMap.update_tile(lm, pos, game.rules) do
          {:ok, lm} ->
            {lm, [{:cook, pos} | logs]}

          :error ->
            {lm, logs}
        end
      end)

    {%{game | levelmap: lmap}, Enum.reverse(inv_logs)}
  end

  defp robot_step_tick(game, no) do
    %{interpreters: is} = game
    robot_step_tick_loop(game, no, is |> elem(no) |> Interpreter.step())
  end

  defp robot_step_tick_loop(game, no, result) do
    case result do
      {:ok, interp} ->
        robot_step_tick_loop(game, no, Interpreter.step(interp))

      {:continue, check, cont} ->
        result = LevelMap.check_sensor(game.levelmap, check, no, game.rules)
        robot_step_tick_loop(game, no, Interpreter.step_continue(cont, result))

      {:yield, action, interp} ->
        new_game = Map.update!(game, :interpreters, &put_elem(&1, no, interp))
        {:action, action, new_game}

      {:error, error, interp} ->
        new_game = Map.update!(game, :interpreters, &put_elem(&1, no, interp))
        {:error, error, new_game}
    end
  end

  defp build_interpreters(asts) do
    asts
    |> Tuple.to_list()
    |> Enum.map(&Interpreter.new(&1))
    |> List.to_tuple()
  end

  defp update_game_status(game = %{goal: goal}) do
    %{game | status: Goal.check(goal, game)}
  end

  defp all_robots_terminated?(game) do
    game.interpreters
    |> Tuple.to_list()
    |> Enum.all?(&Interpreter.terminated?/1)
  end

  defp goal_settled?(game) do
    {overall, _} = game.status
    overall in [:failed, :complete]
  end

  defmodule Goal do
    defstruct objectives: []

    @opaque t :: %__MODULE__{}
    @type objective :: {:primary | :seconary, [rule, ...]}
    @type rule :: term()
    @type status :: :complete | :incomplete | :failed

    @spec new([objective, ...]) :: t()
    def new(objectives) do
      %__MODULE__{objectives: objectives}
    end

    @spec check(t(), Robocook.Game.t()) :: status()
    def check(%__MODULE__{objectives: objs}, game) do
      [overall | rest] = Enum.map(objs, &check_objective(&1, game))
      {overall, rest}
    end

    @spec check_objective(objective(), Robocook.Game.t()) :: status()
    def check_objective({_type, rules}, game) do
      rules
      |> Enum.map(&check_rule(game, &1))
      |> rules_status()
    end

    defp rules_status([]), do: :complete
    defp rules_status([:complete | rest]), do: rules_status(rest)
    defp rules_status([:incomplete | _rest]), do: :incomplete
    defp rules_status([:failed | _rest]), do: :failed

    defp check_rule(game, {:time_limit, limit}) do
      if game.tick <= limit do
        :complete
      else
        :failed
      end
    end

    defp check_rule(game, {:ast_size, robot_no, count}) do
      case elem(game.asts, robot_no) |> Ast.size() < count do
        true -> :complete
        false -> :failed
      end
    end

    defp check_rule(game, {:robot_at, robot_no, pos}) do
      case LevelMap.get_entity(game.levelmap, pos) do
        {:robot, ^robot_no, _, _} -> :complete
        _ -> :incomplete
      end
    end

    defp check_rule(game, {:robot_terminated, robot_no}) do
      game.interpreters
      |> elem(robot_no)
      |> Interpreter.terminated?()
      |> case do
        true -> :complete
        false -> :incomplete
      end
    end

    defp check_rule(game, {:deliver, items}) do
      check_deliver_item(items, game.levelmap.delivery)
    end

    defp check_deliver_item([], []) do
      :complete
    end

    defp check_deliver_item([_ | _], []) do
      :incomplete
    end

    defp check_deliver_item([name | rest_items], [{:item, name, _} | rest]) do
      check_deliver_item(rest_items, rest)
    end

    defp check_deliver_item([name1 | _], [{:item, name2, _} | _]) when name1 != name2 do
      :failed
    end
  end
end
