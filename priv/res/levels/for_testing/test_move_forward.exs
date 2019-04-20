%{
  ref: "4e6762d9-bfbb-4008-8336-3700011b1c13",
  type: :level,
  title: "Test Move Forward",
  description: "Testing Move Forward",
  goal_description: [
    {:primary, "Move the robot to the destinated location"},
    {:secondary, "Complete in less than 3 seconds"}
  ],
  available_blocks: nil,
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [
    [{:procedure, 0, [
        {:action, :move_forward},
        {:action, :move_forward},
        {:action, :move_forward},
      ]}]
  ],
  rules: [],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {3, 0}}
         ]},
        {:secondary,
         [
           {:time_limit, 3}
         ]}
      ],
      map: %{
        size: {4, 1},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
        ]
      }
    }
  ]
}
