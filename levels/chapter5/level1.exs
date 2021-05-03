%{
  type: :level,
  ref: "5b3b842c-1603-468b-90a9-b285304c75cc",
  title: "Three chefs",
  ast_templates: [nil, nil, nil],
  available_blocks: [:move_forward, :turn_left, :turn_right, :pick_up, :put_down, :chop,
    :if, :if_else, :while, :repeat, :loop, :call, :halt],
  description: "TODO",
  goal_description: [
    primary: "Cook and deliver a salad with tomato and cabbage",
  ],
  info_blocks: [],
  num_players: 3,
  num_robots: 3,
  robot_controls: [0, 1, 2],
  rules: [
    {:chop, :tomato, :chopped_tomato},
    {:chop, :cabbage, :chopped_cabbage},
    {:put_in, :plate, :chopped_tomato},
    {:put_in, :plate, :chopped_cabbage},
    {:craft, :plate, :chopped_tomato, :chopped_cabbage, :salad},
  ],
  scenarios: [
    %{
      goal: [
        primary: [{:deliver, [:salad]}],
      ],
      map: %{
        size: {7, 5},
        data: [
          {{:source, 0, %{item: {:item, :tomato, 0}}}, nil},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:source, 0, %{item: {:item, :cabbage, 0}}}, nil},

          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:board, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:board, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},

          {{:floor, 0, nil}, {:robot, 1, {0, 1}, nil}},
          {{:floor, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:wall, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 2, {0, 1}, nil}},

          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          {{:table, 0, nil}, {:container, :plate, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, {:robot, 0, {0, 1}, nil}},
          {{:floor, 0, nil}, nil},
          {{:floor, 0, nil}, nil},
          {{:delivery, 0, nil}, nil},
        ],
      }
    }
  ],
}
