%{
  type: :level,
  ref: "8240e6fa-68e0-4d72-83dd-edb89a7e146c",
  title: "100% Delivery",
  ast_templates: [nil],
  available_blocks: [
    :move_forward, :turn_left, :turn_right, :pick_up, :put_down, :increment, :decrement, :loop, :while, :repeat, :if, :if_else, :halt
  ],
  description: "TODO",
  goal_description: [
    primary: "Delivery all the tomato dishes on the table",
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
           {:deliver, [:tomato, :tomato, :tomato]}
         ]}
      ],
      map: %{
        size: {3, 7},
        data: [
          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, 1}, nil}},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},
          {{:table, 0, nil}, nil},
        ]
      }
    },

    %{
      goal: [
        {:primary,
         [
           {:deliver, [:tomato, :tomato, :tomato, :tomato, :tomato]}
         ]}
      ],
      map: %{
        size: {3, 7},
        data: [
          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, {:robot, 0, {0, 1}, nil}},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},
          {{:table, 0, nil}, nil},
        ]
      }
    },

    %{
      goal: [
        {:primary,
         [
           {:deliver, [:tomato, :tomato]}
         ]}
      ],
      map: %{
        size: {3, 7},
        data: [
          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, {:item, :tomato, 0}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, 1}, nil}},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},
          {{:table, 0, nil}, nil},
        ]
      }
    },
  ]
}
