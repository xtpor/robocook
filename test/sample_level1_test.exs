defmodule SampleLevel1Test do
  use ExUnit.Case
  alias Robocook.{Level, Game}

  def get_level do
    %{
      ref: "5007bd43-163d-43a5-a13e-4fb48a84d5f8",
      title: "Move in a straight line",
      description: "Tutorial level: move the robot in a straight line",
      goal_description: [
        {:primary, "Move the robot to the destinated location"},
        {:secondary, "Complete in less than 5 seconds"}
      ],
      num_players: 1,
      num_robots: 1,
      robot_controls: [0],
      ast_templates: [nil],
      rules: [],
      scenarios: [
        %{
          goal: [
            {:primary,
             [
               {:robot_at, 0, {4, 1}}
             ]},
            {:seconary,
             [
               {:time_limit, 3}
             ]}
          ],
          map: %{
            size: {6, 3},
            data: [
              # 1st row
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},

              # 2nd row
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 1, nil}, nil},
              {{:floor, 0, nil}, nil},

              # 3rd row
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil}
            ]
          }
        }
      ]
    }
  end

  test "using the 3 forwards" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0,
       [
         {:action, :move_forward},
         {:action, :move_forward},
         {:action, :move_forward}
       ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:tick, 0, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:tick, 1, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:tick, 2, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:end, {:complete, [:complete]}} = Game.simulate_tick(game)
  end

  test "using the a loop block" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0,
       [
         {:loop,
          [
            {:action, :move_forward}
          ]}
       ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:tick, 0, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:tick, 1, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:tick, 2, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:end, {:complete, [:complete]}} = Game.simulate_tick(game)
  end

  test "failed the seconard objective with some extraneous blocks" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0,
       [
         {:action, :turn_left},
         {:action, :turn_right},
         {:action, :move_forward},
         {:action, :move_forward},
         {:action, :move_forward}
       ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:tick, 0, [{:action, 0, :turn_left}], game} = Game.simulate_tick(game)
    assert {:tick, 1, [{:action, 0, :turn_right}], game} = Game.simulate_tick(game)
    assert {:tick, 2, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:tick, 3, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:tick, 4, [{:action, 0, :move_forward}], game} = Game.simulate_tick(game)
    assert {:end, {:complete, [:failed]}} = Game.simulate_tick(game)
  end

  test "infinite move backward" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0,
       [
         {:action, :turn_right},
         {:action, :turn_right},
         {:loop,
          [
            {:action, :move_forward}
          ]}
       ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:incomplete, [:failed]} = Game.simulate_result(game)
  end

  test "infinite loop" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0,
       [
         {:loop, []}
       ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:tick, 0, [{:robot_error, 0, :instruction_limit}], game} = Game.simulate_tick(game)
    assert {:end, {:incomplete, [:complete]}} = Game.simulate_tick(game)
  end

  test "infinite recusion" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0,
       [
         {:call, 1}
       ]},
      {:procedure, 1,
       [
         {:call, 1}
       ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast])
    assert {:tick, 0, [{:robot_error, 0, :stack_limit}], game} = Game.simulate_tick(game)
    assert {:end, {:incomplete, [:complete]}} = Game.simulate_tick(game)
  end
end
