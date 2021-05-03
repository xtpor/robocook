%{
  ref: "17289933-6972-493b-a328-acc0f6812c80",
  type: :level,
  title: "4 Players Test 1",
  description: "Move the robot in a straight line",
  goal_description: [
    {:primary, "Move the robot to the destinated location"},
    {:secondary, "Complete in less than 3 seconds"}
  ],
  available_blocks: nil,
  info_blocks: [],
  num_players: 4,
  num_robots: 4,
  robot_controls: [0, 1, 2, 3],
  ast_templates: [nil, nil, nil, nil],
  rules: [],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {2, 0}},
           {:robot_at, 1, {2, 2}},
           {:robot_at, 2, {0, 2}},
           {:robot_at, 3, {0, 0}},
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
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 1, {0, 1}, nil}},

          # 2nd row
          {{:floor, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          # 3rd row
          {{:floor, 0, nil}, {:robot, 3, {0, -1}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 2, {-1, 0}, nil}},
        ]
      }
    }
  ]
}
