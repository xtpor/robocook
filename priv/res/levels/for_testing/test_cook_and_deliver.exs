%{
  ref: "800f3766-289c-471e-a350-f2c88d327779",
  type: :level,
  title: "Test cook and deliver",
  description: "Test cook and deliver",
  goal_description: [
    {:primary, "Deliver a cabbage salad"},
    {:secondary, "Complete in less than 10 seconds"}
  ],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [
    [{:procedure, 0, [
        {:action, :pick_up},
        {:action, :turn_right},
        {:action, :put_down},
        {:action, :chop},
        {:action, :pick_up},
        {:action, :turn_right},
        {:action, :put_down},
        {:action, :pick_up},
        {:action, :turn_right},
        {:action, :put_down},
      ]}]
  ],
  rules: [
    {:chop, :cabbage, :chopped_cabbage},
    {:put_in, :plate, :chopped_cabbage}
  ],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:deliver, [:chopped_cabbage]}
         ]},
        {:secondary,
         [
           {:time_limit, 10}
         ]}
      ],
      map: %{
        size: {3, 3},
        data: [
          # 1st row
          {{:table, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          # 2rd row
          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:source, 0, %{item: {:item, :cabbage, 0}}}, nil},

          # 3nd row
          {{:table, 0, nil}, nil},
          {{:board, 0, nil}, nil},
          {{:table, 0, nil}, nil},
        ]
      }
    }
  ]
}
