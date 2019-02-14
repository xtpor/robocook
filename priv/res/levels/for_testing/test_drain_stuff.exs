%{
  ref: "e622098e-8a02-4c13-83aa-aefba9ff29d0",
  type: :level,
  title: "Test drain item and container",
  description: "Test drain item and container",
  goal_description: [
    {:primary, "Throw away all the bad ingredients"},
    {:secondary, "Complete in less than 7 seconds"}
  ],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [
    [{:procedure, 0, [
        {:action, :turn_right},
        {:action, :pick_up},
        {:action, :turn_left},
        {:action, :put_down},
        {:action, :turn_left},
        {:action, :pick_up},
        {:action, :turn_right},
        {:action, :put_down},
      ]}]
  ],
  rules: [
  ],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:drain, [:bad_banana, :bad_apple]}
         ]},
        {:secondary,
         [
           {:time_limit, 8}
         ]}
      ],
      map: %{
        size: {3, 2},
        data: [
          # 1st row
          {{:table, 0, nil}, nil},
          {{:drain, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          # 2rd row
          {{:table, 0, nil}, {:container, :plate, {:item, :bad_banana, 0}}},
          {{:table, 0, nil}, {:robot, 0, {0, -1}, nil}},
          {{:table, 0, nil}, {:item, :bad_apple, 0}},
        ]
      }
    }
  ]
}
