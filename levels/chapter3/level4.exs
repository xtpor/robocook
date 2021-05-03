%{
  type: :level,
  ref: "6399103b-603a-4b6e-9e71-aa3c8188a458",
  title: "Obstacle course",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :loop, :while, :repeat, :if, :if_else, :halt],
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
        {:primary, [ {:robot_at, 0, {8, 1}} ]}
      ],
      map: %{
        size: {9, 2},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
        ]
      }
    },

    %{
      goal: [
        {:primary, [ {:robot_at, 0, {8, 0}} ]}
      ],
      map: %{
        size: {9, 2},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ]
      }
    },

    %{
      goal: [
        {:primary, [ {:robot_at, 0, {8, 1}} ]}
      ],
      map: %{
        size: {9, 2},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
        ]
      }
    },
  ]
}
