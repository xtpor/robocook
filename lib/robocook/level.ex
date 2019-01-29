defmodule Robocook.Level do
  alias Robocook.Game

  def pick_scenario(level, asts) do
    %{rules: rules} = level

    level.scenarios
    |> Enum.map(fn s -> Game.new(goal: s.goal, rules: rules, levelmap: s.map, asts: asts) end)
    |> Enum.min_by(fn game ->
      result = Game.simulate_result(game)
      {goal_completed?(result), goal_completed?(result)}
    end)
  end

  def goal_completed?({overall, _}) do
    overall == :complete
  end

  def points_earned({overall, secondaries}) do
    if overall == :complete do
      secondaries |> Enum.filter(&(&1 == :complete)) |> length()
    else
      0
    end
  end
end
