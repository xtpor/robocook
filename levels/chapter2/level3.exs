%{
  type: :level,
  ref: "cf240e45-a5ec-48d0-a5d5-45b24490336e",
  title: "Looping practise 3",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :loop],
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
        primary: [{:robot_at, 0, {7, 0}}],
      ],
      map: %{
        size: {9, 1},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
        ],
      }
    },
    %{
      goal: [
        primary: [{:robot_at, 0, {6, 0}}],
      ],
      map: %{
        size: {9, 1},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ],
      }
    },
    %{
      goal: [
        primary: [{:robot_at, 0, {5, 0}}],
      ],
      map: %{
        size: {9, 1},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ],
      }
    },
    %{
      goal: [
        primary: [{:robot_at, 0, {4, 0}}],
      ],
      map: %{
        size: {9, 1},
        data: [
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 1, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
        ],
      }
    }
  ],
}
