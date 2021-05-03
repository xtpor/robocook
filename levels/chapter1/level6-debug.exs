%{
  type: :level,
  ref: "fb26931e-0341-4e13-aa48-eb4e58bbe574",
  title: "Debug: Basic movement",
  ast_templates: [
    [
      {:procedure, 0, [
        {:action, :move_forward},
        {:action, :move_forward},
        {:action, :turn_left},
        {:action, :move_forward},
        {:action, :move_forward},
        {:action, :turn_left},
        {:action, :move_forward},
        {:action, :turn_right},
        {:action, :move_forward},
        {:action, :move_forward},
        {:action, :turn_right},
        {:action, :move_forward},
        {:action, :move_forward},
      ]}
    ]
  ],
  available_blocks: [:move_forward, :turn_left, :turn_right],
  description: "TODO",
  goal_description: [
    primary: "Move the robot to the destinated location",
  ],
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  rules: [
  ],
  scenarios: [
    %{
      goal: [
        primary: [{:robot_at, 0, {0, 4}}],
      ],
      map: %{
        size: {3, 5},
        data: [
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {-1, 0}, nil}},

          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ],
      }
    }
  ],
}
