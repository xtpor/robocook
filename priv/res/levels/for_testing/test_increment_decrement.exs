%{
  ref: "a94a6c99-574f-4eb2-baf8-4b55a81f6a84",
  type: :level,
  title: "Test increment and decrement",
  description: "Test cook and deliver",
  goal_description: [
    {:primary, "Set the counter to 5 and set it to the destination"},
    {:secondary, "Complete in less than 10 seconds"}
  ],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [
    [{:procedure, 0, [
        {:action, :pick_up},
        {:action, {:increment, 5}},
        {:action, :turn_right},
        {:action, :turn_right},
        {:action, :move_forward},
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
           {:check_counter, 5, {3, 0}}
         ]},
        {:secondary,
         [
           {:time_limit, 10}
         ]}
      ],
      map: %{
        size: {4, 1},
        data: [
          # 1st row
          {{:table, 0, nil}, {:counter, 0, 0, 5}},
          {{:floor, 0, nil}, {:robot, 0, {-1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},
        ]
      }
    }
  ]
}
