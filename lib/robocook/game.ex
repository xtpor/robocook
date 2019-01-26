defmodule Robocook.Game do
  alias Robocook.{LevelMap, Compiler, Interpreter}
  alias Robocook.Game.Goal

  def new(goals, rules, asts, levelmap) do
    game =
      %{
        goals: goals,
        rules: rules,
        tick: 0,
        asts: asts,
        interpreters: build_interpreters(asts),
        levelmap: levelmap,
        status: nil
      }
    update_game_status(game)
  end

  def simulate_tick(game) do
    {game, logs1} = simulate_all_robots(game)
    {game, logs2} = update_level_map(game)
    game = update_game_status(game)
    game = Map.update!(game, :tick, &(&1 + 1))
    {game, logs1 ++ logs2}
  end

  defp simulate_all_robots(game) do
    {game, logs} =
      (0..tuple_size(game.interpreters) - 1)
      |> Enum.reduce({game, []}, fn no, {game, logs} ->
        case robot_step_tick(game, no) do
          {:action, action, game} ->
            case LevelMap.perform_action(game.levelmap, action, no, game.rules) do
              {:ok, levelmap} ->
                {%{game | levelmap: levelmap}, [{:action, no, action} | logs]}

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
      for i <- 0..sx - 1, j <- 0..sy - 1 do {i, j} end
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
        robot_step_tick_loop(game, no, Interpreter.check_continue(cont, result))

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

  defp update_game_status(game = %{goals: goals}) do
    %{game | status: Goal.check(goals, game)}
  end

  defmodule Goal do
    @type goals :: [goal]
    @type goal :: {:primary | :seconary, [rule, ...]}
    @type rule :: term()

    def new(goals) do
      goals
    end

    def check(goals, game) do
      Enum.map(goals, &check_goal(game, &1))
    end

    def check_goal(game, {goal_type, rules}) do
      statues = Enum.map(rules, &check_rule(game, &1))
      goal_status = rules_status(statues)
      {goal_type, statues, goal_status}
    end

    def rules_status([]), do: :complete
    def rules_status([:complete | rest]), do: rules_status(rest)
    def rules_status([:incomplete | _rest]), do: :incomplete
    def rules_status([:failed | _rest]), do: :failed

    def check_rule(game, {:time_limit, limit}) do
      if game.tick <= limit do
        :complete
      else
        :failed
      end
    end

    def check_rule(game, {:ast_size, robot_no, count}) do
      case elem(game.asts, robot_no) |> Compiler.ast_size() < count do
        true -> :complete
        false -> :failed
      end
    end

    def check_rule(game, {:robot_at, robot_no, pos}) do
      case LevelMap.get_entity(game.levelmap, pos) do
        {:robot, ^robot_no, _, _} -> :complete
        _ -> :incomplete
      end
    end
  end
end
