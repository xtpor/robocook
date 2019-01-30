defmodule RobocookTest do
  use ExUnit.Case
  alias Robocook.{LevelMap, GameRule}

  setup do
    level =
      LevelMap.new({4, 3})
      |> LevelMap.put_tile({0, 0}, {:source, 0, %{item: {:item, :cabbage, 0}}})
      |> LevelMap.put_tile({0, 1}, {:source, 0, %{item: {:item, :tomato, 0}}})
      |> LevelMap.put_tile({0, 2}, {:table, 0, nil})
      |> LevelMap.put_tile({1, 2}, {:table, 0, nil})
      |> LevelMap.put_tile({2, 2}, {:board, 0, nil})
      |> LevelMap.put_tile({3, 2}, {:delivery, 0, nil})
      |> LevelMap.put_tile({1, 0}, {:floor, 0, nil})
      |> LevelMap.put_tile({2, 0}, {:floor, 0, nil})
      |> LevelMap.put_tile({3, 0}, {:floor, 0, nil})
      |> LevelMap.put_tile({1, 1}, {:floor, 0, nil})
      |> LevelMap.put_tile({2, 1}, {:floor, 0, nil})
      |> LevelMap.put_tile({3, 1}, {:floor, 0, nil})
      |> LevelMap.put_entity({2, 0}, {:robot, 0, {0, 1}, nil})
      |> LevelMap.put_entity({1, 2}, {:container, :plate, nil})

    rules =
      GameRule.new([
        {:chop, :cabbage, :chopped_cabbage},
        {:chop, :tomato, :chopped_tomato},
        {:put_in, :plate, :chopped_cabbage},
        {:put_in, :plate, :chopped_tomato},
        {:craft, :plate, :chopped_tomato, :chopped_cabbage, :salad}
      ])

    %{level: level, rules: rules}
  end

  test "make a salad", ctx do
    %{level: level, rules: rules} = ctx

    # Grab the cabbage
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, :move_forward, level} = LevelMap.perform_action(level, :move_forward, 0, rules)
    {:ok, {:pick_source, {:item, :cabbage, 0}}, level} =
      LevelMap.perform_action(level, :pick_up, 0, rules)

    # Chop the cabbage
    {:ok, :turn_left, level} = LevelMap.perform_action(level, :turn_left, 0, rules)
    {:ok, :move_forward, level} = LevelMap.perform_action(level, :move_forward, 0, rules)
    {:ok, :turn_left, level} = LevelMap.perform_action(level, :turn_left, 0, rules)
    {:ok, :move_forward, level} = LevelMap.perform_action(level, :move_forward, 0, rules)
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, {:put_item, nil, {:item, :cabbage, 0}}, level} = LevelMap.perform_action(level, :put_down, 0, rules)
    {:ok, {:chopped, {:item, :chopped_cabbage, 0}}, level} =
      LevelMap.perform_action(level, :chop, 0, rules)

    # Put the cabbage on the plate
    {:ok, {:pick_item, {:item, :chopped_cabbage, 0}, nil}, level} =
      LevelMap.perform_action(level, :pick_up, 0, rules)
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, :move_forward, level} = LevelMap.perform_action(level, :move_forward, 0, rules)
    {:ok, :turn_left, level} = LevelMap.perform_action(level, :turn_left, 0, rules)
    {:ok, {:put_item, nil, {:container, :plate, {:item, :chopped_cabbage, 0}}}, level} =
      LevelMap.perform_action(level, :put_down, 0, rules)

    # Grab the tomato
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, {:pick_source, {:item, :tomato, 0}}, level} =
      LevelMap.perform_action(level, :pick_up, 0, rules)
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, :move_forward, level} = LevelMap.perform_action(level, :move_forward, 0, rules)
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, {:put_item, nil, {:item, :tomato, 0}}, level} =
      LevelMap.perform_action(level, :put_down, 0, rules)
    {:ok, {:chopped, {:item, :chopped_tomato, 0}}, level} =
      LevelMap.perform_action(level, :chop, 0, rules)

    # Put the tomato on the plate to make a salad
    {:ok, {:pick_item, {:item, :chopped_tomato, 0}, nil}, level} = LevelMap.perform_action(level, :pick_up, 0, rules)
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, :move_forward, level} = LevelMap.perform_action(level, :move_forward, 0, rules)
    {:ok, :turn_left, level} = LevelMap.perform_action(level, :turn_left, 0, rules)
    {:ok, {:put_item, nil, {:container, :plate, {:item, :salad, 0}}}, level} = LevelMap.perform_action(level, :put_down, 0, rules)

    # Deliver that plate
    {:ok, {:pick_item, {:container, :plate, {:item, :salad, 0}}, nil}, level} =
      LevelMap.perform_action(level, :pick_up, 0, rules)
    {:ok, :turn_left, level} = LevelMap.perform_action(level, :turn_left, 0, rules)
    {:ok, :move_forward, level} = LevelMap.perform_action(level, :move_forward, 0, rules)
    {:ok, :move_forward, level} = LevelMap.perform_action(level, :move_forward, 0, rules)
    {:ok, :turn_right, level} = LevelMap.perform_action(level, :turn_right, 0, rules)
    {:ok, {:delivered, {:item, :salad, 0}}, level} = LevelMap.perform_action(level, :put_down, 0, rules)

    assert level.delivery == [{:item, :salad, 0}]
  end

  test "cooking steak" do
    level =
      LevelMap.new({2, 2})
      |> LevelMap.put_tile({0, 0}, {:table, 0, nil})
      |> LevelMap.put_tile({1, 0}, {:stove, 0, nil})
      |> LevelMap.put_tile({0, 1}, {:stove, 0, nil})
      |> LevelMap.put_tile({1, 1}, {:oven, 0, nil})
      |> LevelMap.put_entity({0, 0}, {:container, :pan, {:item, :raw_steak, 0}})
      |> LevelMap.put_entity({1, 0}, {:item, :raw_steak, 0})
      |> LevelMap.put_entity({0, 1}, {:container, :pan, {:item, :raw_steak, 0}})
      |> LevelMap.put_entity({1, 1}, {:container, :pan, {:item, :raw_steak, 0}})

    rules = [
      {:cook, :stove, :pan, :raw_steak, :cooked_steak, 2}
    ]

    assert :error = LevelMap.update_tile(level, {0, 0}, rules)
    assert :error = LevelMap.update_tile(level, {1, 0}, rules)
    assert {:ok, level2} = LevelMap.update_tile(level, {0, 1}, rules)
    assert :error = LevelMap.update_tile(level, {1, 1}, rules)

    assert {:container, :pan, {:item, :raw_steak, 1}} = LevelMap.get_entity(level2, {0, 1})
    assert {:ok, level3} = LevelMap.update_tile(level2, {0, 1}, rules)

    assert {:container, :pan, {:item, :cooked_steak, 0}} = LevelMap.get_entity(level3, {0, 1})
  end
end
