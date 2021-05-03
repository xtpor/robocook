%{
  type: :level,
  ref: "908962dd-8c94-4dee-a828-259fecf8d99a",
  title: "The basic: Movement 1",
  ast_templates: [nil],
  available_blocks: [:move_forward],
  description: "TODO",
  goal_description: [
    primary: "Move the robot to the destinated location",
  ],
  info_blocks: ["how_to_play1", "how_to_play2", "how_to_play3", "how_to_play4"],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  rules: [],
  scenarios: [
    %{
      goal: [
        primary: [{:robot_at, 0, {3, 1}}],
      ],
      map: %{
        size: {5, 3},
        data: [
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ],
      }
    }
  ],
}
