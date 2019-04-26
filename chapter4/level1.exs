%{
  type: :level,
  ref: "5017a4ec-e519-4c94-9e00-ee5fa8f184f6",
  title: "Procedure basic",
  ast_templates: [
    [
      {:procedure, 0, [
      ]},
      {:procedure, 1, [
        {:action, :move_forward},
        {:action, :move_forward},
        {:action, :move_forward},
        {:action, :move_forward},
        {:action, :move_forward},
      ]},
      {:procedure, 2, [
        {:action, :move_forward},
        {:action, :move_forward},
      ]},
    ]
  ],
  available_blocks: [:turn_left, :turn_right, :call],
  description: "TODO",
  goal_description: [
    primary: "Move the robot to the destinated location",
  ],
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  rules: [],
  scenarios: [
    %{
      goal: [
        primary: [{:robot_at, 0, {5, 4}}],
      ],
      map: %{
        size: {6, 5},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
        ],
      }
    }
  ],
}
