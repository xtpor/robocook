%{
  type: :level,
  ref: "0f4749df-5bfc-4e7d-a9fa-f81d3e4739ae",
  title: "Recursion basic",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :call],
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
        primary: [{:robot_at, 0, {4, 0}}],
      ],
      map: %{
        size: {5, 5},
        data: [
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},

          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},

          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
        ],
      }
    }
  ],
}
