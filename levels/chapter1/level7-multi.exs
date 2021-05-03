%{
  type: :level,
  ref: "00f71da7-0959-4bd1-bf24-18f744c28173",
  title: "Multiplayer 1",
  ast_templates: [nil, nil],
  available_blocks: [:move_forward, :turn_left, :turn_right],
  description: "TODO",
  goal_description: [
    primary: "Move the robot to the destinated location",
  ],
  info_blocks: [],
  num_players: 2,
  num_robots: 2,
  robot_controls: [0, 1],
  rules: [
  ],
  scenarios: [
    %{
      goal: [
        primary: [{:robot_at, 0, {6, 1}}, {:robot_at, 1, {0, 1}}],
      ],
      map: %{
        size: {7, 3},
        data: [
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},

          {{:floor, 2, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 1, {-1, 0}, nil}},
          {{:floor, 1, nil}, nil},

          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:void, 0, nil}, nil},
          {{:void, 0, nil}, nil},
        ],
      }
    }
  ],
}
