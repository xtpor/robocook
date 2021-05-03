%{
  type: :level,
  ref: "5546fbcf-a46d-47c9-857d-7881bdbda30c",
  title: "The basic: Movement 2",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right],
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
        primary: [{:robot_at, 0, {3, 3}}],
      ],
      map: %{
        size: {5, 5},
        data: [
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {-1, 0}, nil}},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ],
      }
    }
  ],
}
