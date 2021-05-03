%{
  type: :level,
  ref: "75d8f849-6328-4d6d-bf53-57e5dfdf036f",
  title: "Looping practice 2",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :repeat],
  description: "TODO",
  goal_description: [
    primary: "Move the robot to the destinated location",
  ],
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  rules: [],
  scenarios: [
    %{
      goal: [
        primary: [{:robot_at, 0, {1, 0}}],
      ],
      map: %{
        size: {5, 5},
        data: [
          {{:void, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, 1}, nil}},
          {{:void, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
        ],
      }
    }
  ],
}
