%{
  ref: "bf6d2de1-5233-4ad8-a269-3e84d8763a2c",
  type: :level,
  title: "Demo Level",
  description: "Use procedure effectively",
  goal_description: [
    {:primary, "Cook and delivery all 4 dishes on the map"},
  ],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [nil],
  rules: [],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {0, 0}}
         ]}
      ],
      map: %{
        size: {6, 6},
        data: [
          # 1st row
          {{:table, 0, nil}, nil},
          {{:source, 0, %{item: {:item, :red, 0}}}, nil},
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
          {{:source, 0, %{item: {:item, :blue, 0}}}, nil},

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
          {{:source, 0, %{item: {:item, :green, 0}}}, nil},
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
          {{:source, 0, %{item: {:item, :yellow, 0}}}, nil},
          {{:table, 0, nil}, nil},
        ]
      }
    }
  ]
}
