defmodule SampleLevel2Test do
  use ExUnit.Case
  alias Robocook.{Level, Game}

  def get_level do
    %{
      ref: "5007bd43-163d-43a5-a13e-4fb48a84d5f8",
      title: "According to the counter",
      description: "Tutorial level: move the robot in a straight line",
      goal_description: [
        {:primary, "Move the robot to the destinated location"},
      ],
      num_players: 1,
      num_robots: 1,
      robot_controls: [0],
      ast_templates: [nil],
      rules: [],
      scenarios: [
        # counter with value 1
        %{
          goal: [
            {:primary,
             [
               {:robot_at, 0, {1, 0}},
               {:robot_terminated, 0},
             ]},
          ],
          map: %{
            size: {4, 1},
            data: [
              # 1st row
              {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 1, 0, 3}}},
              {{:floor, 1, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
            ]
          }
        },

        # counter with value 2
        %{
          goal: [
            {:primary,
             [
               {:robot_at, 0, {2, 0}},
               {:robot_terminated, 0},
             ]},
          ],
          map: %{
            size: {4, 1},
            data: [
              # 1st row
              {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 2, 0, 3}}},
              {{:floor, 1, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
            ]
          }
        },

        # counter with value 3
        %{
          goal: [
            {:primary,
             [
               {:robot_at, 0, {3, 0}},
               {:robot_terminated, 0},
             ]},
          ],
          map: %{
            size: {4, 1},
            data: [
              # 1st row
              {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 3, 0, 3}}},
              {{:floor, 1, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
            ]
          }
        },
      ]
    }
  end

  test "using the correct answer" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0, [
        {:while, {:test, {:check_counter, :gt, 0}}, [
          {:action, :move_forward},
          {:action, {:decrement, 1}}
        ]}
      ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:complete, []} = Game.simulate_result(game)
  end

  test "hard coding attempt #1" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0, [
        {:action, :move_forward},
      ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:incomplete, []} = Game.simulate_result(game)
  end

  test "hard coding attempt #2" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0, [
        {:action, :move_forward},
        {:action, :move_forward},
      ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:incomplete, []} = Game.simulate_result(game)
  end

  test "hard coding attempt #3" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0, [
        {:action, :move_forward},
        {:action, :move_forward},
        {:action, :move_forward},
      ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:incomplete, []} = Game.simulate_result(game)
  end

end
