%{
  ref: "b2922052-7df4-48ab-be4b-32e890c61717",
  type: :level,
  title: "Test pickup and putdown",
  description: "Test pickup and putdown",
  goal_description: [
    {:primary, "Move put the apple on destinated table"},
    {:secondary, "Complete in less than 5 seconds"}
  ],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [
    [{:procedure, 0, [
        {:action, :pick_up},
        {:action, :turn_right},
        {:action, :turn_right},
        {:action, :move_forward},
        {:action, :put_down},
      ]}]
  ],
  rules: [],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:item_at, :apple, {0, 0}}
         ]},
        {:secondary,
         [
           {:time_limit, 5}
         ]}
      ],
      map: %{
        size: {4, 1},
        data: [
          {{:table, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:table, 0, nil}, {:item, :apple, 0}},
        ]
      }
    }
  ]
}
