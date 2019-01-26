defmodule Data do
  alias Robocook.LevelMap
  alias Robocook.Game

  def test1 do
    goals = [
      {:primary, [
        {:robot_at, 0, {1, 1}},
        {:robot_at, 1, {0, 0}},
      ]}
    ]

    rules = []

    levelmap =
      LevelMap.new({2, 2})
      |> LevelMap.put_tile({0, 0}, {:floor, 0, nil})
      |> LevelMap.put_tile({1, 0}, {:floor, 0, nil})
      |> LevelMap.put_tile({0, 1}, {:floor, 0, nil})
      |> LevelMap.put_tile({1, 1}, {:floor, 0, nil})
      |> LevelMap.put_entity({0, 0}, {:robot, 0, {1, 0}, nil})
      |> LevelMap.put_entity({1, 1}, {:robot, 1, {-1, 0}, nil})

    asts = {
      [
        {:procedure, 0, [
          {:action, :move_forward},
          {:action, :turn_right},
          {:action, :move_forward},
        ]}
      ],
      [
        {:procedure, 0, [
          {:action, :move_forward},
          {:action, :move_forward},
          {:action, :turn_right},
          {:action, :move_forward},
        ]}
      ],
    }

    Game.new(goals, rules, asts, levelmap)
  end

end
