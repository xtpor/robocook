%{
  type: :level,
  ref: "65b01dae-7718-41bb-bbdf-40d98b91c6bb",
  title: "Count to zero",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :increment, :decrement, :loop, :while, :repeat, :if, :if_else, :halt],
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
        {:primary,
         [
           {:robot_at, 0, {4, 1}},
           {:robot_terminated, 0}
         ]}
      ],
      map: %{
        size: {6, 3},
        data: [
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 3, 0, 3}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ]
      }
    },
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {2, 1}},
           {:robot_terminated, 0}
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

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 1, 0, 3}}},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ]
      }
    },
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {3, 1}},
           {:robot_terminated, 0}
         ]}
      ],
      map: %{
        size: {6, 3},
        data: [
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 2, 0, 3}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ]
      }
    },
  ]
}
