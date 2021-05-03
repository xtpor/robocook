%{
  ref: "cddd739e-fac5-48de-a645-5aa56c62b74b",
  type: :level,
  title: "Basic movement 2",
  description: "Learn how to use the turn instruction",
  goal_description: [
    {:primary, "Move the robot to the marked location on the map"},
    {:secondary, "Complete in less than 8 seconds"}
  ],
  available_blocks: nil,
  info_blocks: [],
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
           {:robot_at, 0, {2, 2}}
         ]},
        {:secondary,
         [
           {:time_limit, 8}
         ]}
      ],
      map: %{
        size: {3, 3},
        data: [
          # 1st row
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {-1, 0}, nil}},

          # 2nd row
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:wall, 0, nil}, nil},

          # 3rd row
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
        ]
      }
    }
  ]
}
