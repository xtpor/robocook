%{
  ref: "5007bd43-163d-43a5-a13e-4fb48a84d5f8",
  type: :level,
  title: "Basic movement (2 Players)",
  description: "Move the robot in a straight line",
  goal_description: [
    {:primary, "Move the robot to the destinated location"},
    {:secondary, "Complete in less than 3 seconds"}
  ],
  num_players: 2,
  num_robots: 2,
  robot_controls: [0, 1],
  rules: [nil, nil],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {0, 0}},
           {:robot_at, 1, {2, 2}}
         ]},
        {:secondary,
         [
           {:time_limit, 2}
         ]}
      ],
      map: %{
        size: {3, 3},
        data: [
          # 1st row
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 1, {0, 1}, nil}},

          # 2nd row
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          # 3rd row
          {{:floor, 0, nil}, {:robot, 0, {0, -1}, nil}},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ]
      }
    }
  ]
}
