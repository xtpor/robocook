%{
  ref: "9ab1ca04-49f3-4166-8b70-7f11d3b92c93",
  type: :level,
  title: "Looping Pratice 1",
  description: "There is a counter block in front of you showing how many blocks you should move forward, e.g. if the number is 3 you should move 3 steps forward",
  goal_description: [
    {:primary, "Move the robot to the destinated location"}
  ],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [nil],
  rules: [],
  scenarios: [
    # counter with value 1
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {1, 0}},
           {:robot_terminated, 0}
         ]}
      ],
      map: %{
        size: {4, 1},
        data: [
          # 1st row
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 1, 0, 3}}},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil}
        ]
      }
    },

    # counter with value 2
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {2, 0}},
           {:robot_terminated, 0}
         ]}
      ],
      map: %{
        size: {4, 1},
        data: [
          # 1st row
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 2, 0, 3}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil}
        ]
      }
    },

    # counter with value 3
    %{
      goal: [
        {:primary,
         [
           {:robot_at, 0, {3, 0}},
           {:robot_terminated, 0}
         ]}
      ],
      map: %{
        size: {4, 1},
        data: [
          # 1st row
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:counter, 3, 0, 3}}},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil}
        ]
      }
    }
  ]
}
