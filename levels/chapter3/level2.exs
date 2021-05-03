%{
  type: :level,
  ref: "3282abf8-9a9d-4a44-befa-a1b295411061",
  title: "Transfer value",
  ast_templates: [nil],
  available_blocks: [
    :move_forward, :turn_left, :turn_right, :pick_up, :put_down, :increment, :decrement, :loop, :while, :repeat, :if, :if_else, :halt
  ],
  description: "TODO",
  goal_description: [
    primary: "Copy the counter",
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
           {:check_counter, 0, {1, 0}},
           {:check_counter, 5, {3, 0}},
           {:robot_terminated, 0}
         ]}
      ],
      map: %{
        size: {5, 3},
        data: [
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, {:counter, 5, 0, 10}},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, {:counter, 0, 0, 10}},
          {{:table, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, -1}, nil}},
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
           {:check_counter, 0, {1, 0}},
           {:check_counter, 6, {3, 0}},
           {:robot_terminated, 0}
         ]}
      ],
      map: %{
        size: {5, 3},
        data: [
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, {:counter, 6, 0, 10}},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, {:counter, 0, 0, 10}},
          {{:table, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, -1}, nil}},
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
           {:check_counter, 0, {1, 0}},
           {:check_counter, 4, {3, 0}},
           {:robot_terminated, 0}
         ]}
      ],
      map: %{
        size: {5, 3},
        data: [
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, {:counter, 4, 0, 10}},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, {:counter, 0, 0, 10}},
          {{:table, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, -1}, nil}},
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
