%{
  type: :level,
  ref: "b2ab4949-13e0-4e21-9727-d945a8c1d4c5",
  title: "Basic movement 5",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :pick_up, :put_down, :chop],
  description: "TODO",
  goal_description: [
    primary: "Move the robot to the destinated location",
  ],
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  rules: [
    {:put_in, :plate, :chopped_tomato},
    {:chop, :tomato, :chopped_tomato}
  ],
  scenarios: [
    %{
      goal: [
        primary: [{:deliver, [:chopped_tomato]}],
      ],
      map: %{
        size: {5, 5},
        data: [
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          {{:delivery, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:board, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, 1}, nil}},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:source, 0, %{item: {:item, :tomato, nil}}}, nil},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
        ],
      }
    }
  ],
}
