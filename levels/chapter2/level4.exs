%{
  ref: "cc017e0f-dd32-4253-a050-b10a7d46051a",
  type: :level,
  title: "Repetition",
  description: "TODO",
  available_blocks: [:move_forward, :turn_left, :turn_right, :pick_up, :put_down, :chop, :loop, :repeat],
  goal_description: [
    {:primary, "Cook and delivery all four dishes on the map"},
  ],
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [nil],
  rules: [
    {:put_in, :plate, :chopped_tomato},
    {:chop, :tomato, :chopped_tomato}
  ],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:deliver, [:chopped_tomato, :chopped_tomato, :chopped_tomato, :chopped_tomato]}
         ]}
      ],
      map: %{
        size: {6, 6},
        data: [
          # 1st row
          {{:table, 0, nil}, nil},
          {{:source, 0, %{item: {:item, :tomato, 0}}}, nil},
          {{:board, 0, nil}, nil},
          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:delivery, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          # 2nd row
          {{:delivery, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:source, 0, %{item: {:item, :tomato, 0}}}, nil},

          # 3nd row
          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:board, 0, nil}, nil},

          # 4th row
          {{:board, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, {:container, :plate, nil}},

          # 5th row
          {{:source, 0, %{item: {:item, :tomato, 0}}}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},

          # 6th row
          {{:table, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},
          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:board, 0, nil}, nil},
          {{:source, 0, %{item: {:item, :tomato, 0}}}, nil},
          {{:table, 0, nil}, nil},
        ]
      }
    }
  ]
}
