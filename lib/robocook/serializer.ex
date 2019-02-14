defmodule Robocook.Serializer do
  alias Robocook.Ast

  def serialize_level_status({primary, secondaries}) do
    %{
      primary: primary,
      secondaries: secondaries
    }
  end

  def serialize_level_status(nil) do
    nil
  end

  def serialize_goal(level_res) do
    [primary | secondaries] = level_res.goal_description
    {:primary, prim} = primary
    %{primary: prim, secondaries: Enum.map(secondaries, fn {:secondary, desc} -> desc end)}
  end

  def serialize_scenes(level_res) do
    Enum.map(level_res.scenarios, fn %{map: map} -> serialize_map(map) end)
  end

  def serialize_map(map_obj) do
    %{size: {x, y}, data: map_data} = map_obj
    %{size: [x, y], data: Enum.map(map_data, &serialize_map_data_block/1)}
  end

  def serialize_map_data_block(data_block) do
    {tile, entity} = data_block
    %{tile: serialize_tile(tile), entity: serialize_entity(entity)}
  end

  def serialize_tile(nil) do
    nil
  end

  def serialize_tile({tile, variation, extra}) do
    %{type: tile, variation: variation, extra: serialize_tile_extra(extra)}
  end

  def serialize_entity(nil) do
    nil
  end

  def serialize_entity({:robot, no, {dx, dy}, holding}) do
    %{type: :robot, no: no, dir: [dx, dy], holding: serialize_entity(holding)}
  end

  def serialize_entity({:item, name, stage}) do
    %{type: :item, name: name, stage: stage}
  end

  def serialize_entity({:container, name, holding}) do
    %{type: :container, name: name, holding: serialize_entity(holding)}
  end

  def serialize_entity({:counter, count, min, max}) do
    %{type: :counter, count: count, min: min, max: max}
  end

  def serialize_entity({:decor, variation}) do
    %{type: :decor, variation: variation}
  end

  def serialize_tile_extra(nil), do: nil
  def serialize_tile_extra(%{item: item}), do: %{item: serialize_entity(item)}

  def serialize_game_update({:action, no, action, log}) do
    action = Ast.serialize_action(action)
    log = serialize_action_log(log)
    %{type: :action, no: no, action: action, log: log}
  end

  def serialize_game_update({:action_error, no, action}) do
    action = Robocook.Ast.serialize_action(action)
    %{type: :action_error, no: no, action: action}
  end

  def serialize_game_update({:robot_error, no, reason}) do
    %{type: :robot_error, no: no, reason: reason}
  end

  def serialize_game_update({:cook, pos, entity}) do
    %{type: :cooking, pos: serialize_point(pos), item: serialize_entity(entity)}
  end

  def serialize_action_log({:move_forward, fp, tp}) do
    %{type: :move_forward, from: serialize_point(fp), to: serialize_point(tp)}
  end

  def serialize_action_log({:turn_right, pos, new_dir}) do
    %{type: :turn_right, pos: serialize_point(pos), new_dir: serialize_point(new_dir)}
  end

  def serialize_action_log({:turn_left, pos, new_dir}) do
    %{type: :turn_left, pos: serialize_point(pos), new_dir: serialize_point(new_dir)}
  end

  def serialize_action_log({:pick_item, pos, tpos, hand_item, table_item}) do
    %{
      type: :pick_item,
      pos: serialize_point(pos),
      target_pos: serialize_point(tpos),
      holding: serialize_entity(hand_item),
      target_item: serialize_entity(table_item)
    }
  end

  def serialize_action_log({:pick_source, pos, tpos, hand_item}) do
    %{
      type: :pick_source,
      pos: serialize_point(pos),
      target_pos: serialize_point(tpos),
      holding: serialize_entity(hand_item)
    }
  end

  def serialize_action_log({:put_item, pos, tpos, hand_item, table_item}) do
    %{
      type: :put_item,
      pos: serialize_point(pos),
      target_pos: serialize_point(tpos),
      holding: serialize_entity(hand_item),
      target_item: serialize_entity(table_item)
    }
  end

  def serialize_action_log({:drained, pos, tpos, trash, remaining}) do
    %{
      type: :drained,
      pos: serialize_point(pos),
      target_pos: serialize_point(tpos),
      trash: serialize_entity(trash),
      holding: serialize_entity(remaining)
    }
  end

  def serialize_action_log({:delivered, pos, tpos, item}) do
    %{
      type: :delivered,
      pos: serialize_point(pos),
      target_pos: serialize_point(tpos),
      target_item: serialize_entity(item)
    }
  end

  def serialize_action_log({:chopped, tpos, table_item}) do
    %{
      type: :chopped,
      target_pos: serialize_point(tpos),
      target_item: serialize_entity(table_item)
    }
  end

  def serialize_action_log(:wait) do
    nil
  end

  def serialize_action_log({:counter_update, pos, new_count}) do
    %{type: :counter_update, pos: serialize_point(pos), new_count: new_count}
  end

  def serialize_point({x, y}) do
    [x, y]
  end

  def serialize_ast(ast) do
    Ast.serialize(ast)
  end

  def deserialize_ast(ast) do
    try do
      {:ok, Ast.deserialize(ast)}
    rescue
      _err -> :error
    end
  end
end
