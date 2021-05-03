%{
  type: :level,
  ref: "18997215-37db-4e5e-8570-8b41542afd71",
  title: "Basic movement 3",
  ast_templates: [nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :pick_up, :put_down],
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
        primary: [{:item_at, :tomato, {4, 1}}],
      ],
      map: %{
        size: {5, 3},
        data: [
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:table, 0, nil}, {:item, :tomato, 0}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {-1, 0}, nil}},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},

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
