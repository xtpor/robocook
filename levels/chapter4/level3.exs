%{
  ref: "5f06e0b1-400b-43e0-abb1-3c6164218f0d",
  type: :level,
  title: "Mirror the movement",
  description: "TODO",
  available_blocks: [:move_forward, :turn_left, :turn_right, :pick_up, :put_down, :chop, :if, :if_then, :while, :loop, :repeat, :call, :halt],
  goal_description: [
    {:primary, "Cook and delivery all two dishes on the map"},
  ],
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [
    [
      {:procedure, 0, [
        {:call, 2},
        {:action, :move_forward},
        {:action, :move_forward},
        {:call, 2},
      ]},
      {:procedure, 1, [
        {:action, :turn_right},
        {:action, :move_forward},
        {:action, :turn_left},
      ]},
      {:procedure, 2, [
      ]},

    ]
  ],
  rules: [
    {:put_in, :plate, :chopped_tomato},
    {:chop, :tomato, :chopped_tomato},
    {:put_in, :plate, :chopped_cabbage},
    {:chop, :cabbage, :chopped_cabbage},
  ],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:deliver, [:chopped_cabbage, :chopped_tomato]}
         ]}
      ],
      map: %{
        size: {5, 4},
        data: [
          {{:source, 0, %{item: {:item, :tomato, 0}}}, nil},
          {{:board, 0, nil}, nil},
          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:floor, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:source, 0, %{item: {:item, :cabbage, 0}}}, nil},
          {{:board, 0, nil}, nil},
          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:floor, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, -1}, nil}},
          {{:floor, 0, nil}, nil},
        ]
      }
    }
  ]
}
