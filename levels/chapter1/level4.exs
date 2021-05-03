%{
  type: :level,
  ref: "db48c36a-830c-4789-9554-75aee04b910b",
  title: "Basic movement 4",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :pick_up, :put_down],
  description: "TODO",
  goal_description: [
    primary: "Move the robot to the destinated location",
  ],
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  rules: [
    {:put_in, :plate, :tomato}
  ],
  scenarios: [
    %{
      goal: [
        primary: [{:deliver, [:tomato]}],
      ],
      map: %{
        size: {5, 4},
        data: [
          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, {:item, :tomato, 0}},

          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
        ],
      }
    }
  ],
}
