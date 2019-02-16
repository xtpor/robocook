defmodule Robocook.Level do
  alias Robocook.Game

  @empty_ast [{:procedure, 0, []}]

  def pick_scenario(level, asts) do
    %{rules: rules} = level

    level.scenarios
    |> Enum.map(fn s -> Game.new(goal: s.goal, rules: rules, levelmap: s.map, asts: asts) end)
    |> Enum.with_index()
    |> Enum.min_by(fn {game, _index} ->
      result = Game.simulate_result(game)
      {goal_completed?(result), goal_completed?(result)}
    end)
  end

  def goal_completed?({overall, _}) do
    overall == :complete
  end

  def points_earned({overall, secondaries}) do
    if overall == :complete do
      1 + (secondaries |> Enum.filter(&(&1 == :complete)) |> length())
    else
      0
    end
  end

  def generate_initial_asts(level) do
    Enum.map(level.ast_templates, fn
      nil -> @empty_ast
      ast -> ast
    end)
  end
end
