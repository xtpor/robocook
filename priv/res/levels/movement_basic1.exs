%{
  ref: "25c604ab-378a-4d28-ac99-e93b6c1e187f",
  type: :level,
  title: "Basic movement 1",
  description: "Learn how to move the robot in a straight line",
  goal_description: [
    {:primary, "Move the robot to the destinated location"},
    {:secondary, "Complete in less than 3 seconds"}
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
           {:robot_at, 0, {4, 1}}
         ]},
        {:secondary,
         [
           {:time_limit, 3}
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

          # 2nd row
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},

          # 3rd row
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil}
        ]
      }
    }
  ]
}
