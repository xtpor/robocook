%{
  ref: "7462f3be-3cde-4af3-a8cf-af4231ec19f1",
  type: :level,
  title: "Test cook using pan and stove",
  description: "Test cook using pan and stove",
  goal_description: [
    {:primary, "Cook a medium well steak"},
  ],
  available_blocks: nil,
  info_blocks: [],
  num_players: 1,
  num_robots: 1,
  robot_controls: [0],
  ast_templates: [
    [{:procedure, 0, [
        {:action, :put_down},
        {:action, :pick_up},
        {:action, :turn_left},
        {:action, :put_down},
        {:while, {:not, {:test, {:is_item, :medium_well_steak}}}, [
          {:action, :wait}
          ]},
        {:action, :pick_up},
        {:action, :turn_right},
        {:action, :put_down},
      ]}]
  ],
  rules: [
    {:put_in, :pan, :raw_steak},
    {:cook, :stove, :pan, :raw_steak, :rare_steak, 2},
    {:cook, :stove, :pan, :rare_steak, :medium_rare_steak, 2},
    {:cook, :stove, :pan, :medium_rare_steak, :medium_steak, 2},
    {:cook, :stove, :pan, :medium_steak, :medium_well_steak, 2},
    {:cook, :stove, :pan, :medium_well, :welldone_steak, 2},
    {:cook, :stove, :pan, :welldone_steak, :burnt_steak, 2},
  ],
  scenarios: [
    %{
      goal: [
        {:primary,
         [
           {:item_at, :medium_well_steak, {1, 1}}
         ]},
      ],
      map: %{
        size: {2, 2},
        data: [
          # 1st row
          {{:stove, 0, nil}, nil},
          {{:table, 0, nil}, nil},

          # 2rd row
          {{:floor, 0, nil}, {:robot, 0, {1, 0}, {:item, :raw_steak, 0}}},
          {{:table, 1, nil}, {:container, :pan, nil}},
        ]
      }
    }
  ]
}
