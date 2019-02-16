%{
  ref: "23bd991c-fe64-4976-b1c3-3859551664c9",
  type: :level,
  title: "Test turn left and right",
  description: "Test turn left and right",
  goal_description: [
    {:primary, "Move the robot to the destinated location"},
    {:secondary, "Complete in less than 5 seconds"}
  ],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [
    [{:procedure, 0, [
        {:action, :move_forward},
        {:action, :turn_right},
        {:action, :move_forward},
        {:action, :turn_left},
        {:action, :move_forward},
      ]}]
  ],
  rules: [],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {1, 0}}
         ]},
        {:secondary,
         [
           {:time_limit, 5}
         ]}
      ],
      map: %{
        size: {2, 3},
        data: [
          # 1st row
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          # 2rd row
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},

          # 3nd row
          {{:floor, 0, nil}, {:robot, 0, {0, -1}, nil}},
          {{:wall, 0, nil}, nil},
        ]
      }
    }
  ]
}
