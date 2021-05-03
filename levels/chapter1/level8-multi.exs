%{
  type: :level,
  ref: "0fb26d1c-ffb8-456e-9045-ff67181f18d5",
  title: "Multiplayer 2",
  ast_templates: [nil, nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :pick_up, :put_down, :chop, :wait],
  description: "TODO",
  goal_description: [
    primary: "Move the robot to the destinated location",
  ],
  info_blocks: [],
  num_players: 2,
  num_robots: 2,
  robot_controls: [0, 1],
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
        size: {5, 3},
        data: [
          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 1, {1, 0}, nil}},
          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {-1, 0}, nil}},
          {{:table, 0, nil}, nil},

          {{:board, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, {:item, :tomato, 0}},
        ],
      }
    }
  ],
}
