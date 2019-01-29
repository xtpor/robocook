defmodule SampleLevel3Test do
  use ExUnit.Case
  alias Robocook.{Level, Game}

  def get_level do
    %{
      ref: "5007bd43-163d-43a5-a13e-4fb48a84d5f8",
      title: "Deliver a cookie",
      description: "Tutorial level: move the robot in a straight line",
      goal_description: [
        {:primary, "Move the robot to the destinated location"},
      ],
      num_players: 2,
      num_robots: 2,
      robot_controls: [0, 1],
      ast_templates: [nil, nil],
      rules: [],
      scenarios: [
        %{
          goal: [
            {:primary,
             [
               {:deliver, [:cookie]},
             ]},
          ],
          map: %{
            size: {5, 3},
            data: [
              # 1st row
              {{:delivery, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:wall, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:table, 0, nil}, {:container, :plate, {:item, :cookie, 0}}},

              # 2nd row
              {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
              {{:floor, 0, nil}, nil},
              {{:table, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, {:robot, 1, {-1, 0}, nil}},

              # 3rd row
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:wall, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
              {{:floor, 0, nil}, nil},
            ]
          }
        }
      ]
    }
  end

  test "using the correct answer" do
    level = get_level()

    robot0_ast = [
      {:procedure, 0, [
        {:action, :move_forward},
        {:while, {:not, {:test, {:is_item, :cookie}}}, [
          {:action, :wait}
        ]},
        {:action, :pick_up},
        {:action, :turn_left},
        {:action, :turn_left},
        {:action, :move_forward},
        {:action, :turn_right},
        {:action, :put_down},
      ]}
    ]

    robot1_ast = [
      {:procedure, 0, [
        {:action, :turn_right},
        {:action, :pick_up},
        {:action, :turn_left},
        {:action, :move_forward},
        {:action, :put_down},
      ]}
    ]

    game = Level.pick_scenario(level, [robot0_ast, robot1_ast])
    {:tick, 0, _, game} = Game.simulate_tick(game)
    {:tick, 1, _, game} = Game.simulate_tick(game)
    {:tick, 2, _, game} = Game.simulate_tick(game)
    {:tick, 3, _, game} = Game.simulate_tick(game)
    {:tick, 4, _, game} = Game.simulate_tick(game)
    {:tick, 5, _, game} = Game.simulate_tick(game)
    {:tick, 6, _, game} = Game.simulate_tick(game)
    {:tick, 7, _, game} = Game.simulate_tick(game)
    {:tick, 8, _, game} = Game.simulate_tick(game)
    {:tick, 9, _, game} = Game.simulate_tick(game)
    {:tick, 10, _, game} = Game.simulate_tick(game)
    {:end, {:complete, []}} = Game.simulate_tick(game)
  end
end
