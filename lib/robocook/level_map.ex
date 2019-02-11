defmodule Robocook.LevelMap do
  alias Robocook.{Grid, Math, GameRule}

  # warning: functions listed here are considered unsafe
  # using these functions might put the data structure into inconsistent state

  @type tile :: {name :: atom(), variation :: non_neg_integer(), extra :: nil | map()}
  @type direction :: {1, 0} | {-1, 0} | {0, 1} | {0, -1}

  @type item :: {:item, name :: atom(), stage :: non_neg_integer()}

  @type entity ::
          item()
          | {:container, name :: atom(), nil | item()}
          | {:counter, count :: integer(), lower_limit :: integer(), upper_limit :: integer()}
          | {:decoration, variation :: integer()}
          | {:robot, no :: 0..7, direction, nil | item()}

  def new(size) do
    %{
      tiles: Grid.new(size, {:void, 0, nil}),
      entities: Grid.new(size),
      drain: [],
      delivery: []
    }
  end

  def from_ext(%{size: size = {width, height}, data: data}) do
    points =
      for j <- 0..(height - 1), i <- 0..(width - 1) do
        {i, j}
      end

    Enum.zip(points, data)
    |> Enum.reduce(new(size), fn {pt, {tile, entity}}, lm ->
      lm
      |> put_tile(pt, tile)
      |> put_entity(pt, entity)
    end)
  end

  def size(lm) do
    Grid.size(lm.tiles)
  end

  def put_tile(lmap, pt, tile) do
    Map.update!(lmap, :tiles, &Grid.put!(&1, pt, tile))
  end

  def get_tile(lmap, pt) do
    Grid.get(lmap.tiles, pt, {:void, 0, nil})
  end

  def get_tile_type(lmap, pt) do
    {type, _, _} = get_tile(lmap, pt)
    type
  end

  def put_entity(lmap, pt, entity) do
    Map.update!(lmap, :entities, &Grid.put!(&1, pt, entity))
  end

  def get_entity(lmap, pt) do
    Grid.get(lmap.entities, pt)
  end

  def put_robot_item(lmap, pt, item) do
    {:robot, no, dir, _holding} = get_entity(lmap, pt)
    put_entity(lmap, pt, {:robot, no, dir, item})
  end

  def perform_action(lm, :move_forward, no, _rules) do
    pos = find_robot_pos(lm, no)
    entity = {:robot, ^no, dir, _} = get_entity(lm, pos)
    dest = Math.add(pos, dir)

    with {:floor, _, nil} <- get_tile(lm, dest),
         nil <- get_entity(lm, dest) do
      {:ok, :move_forward, lm |> put_entity(pos, nil) |> put_entity(dest, entity)}
    else
      _ -> :error
    end
  end

  def perform_action(lm, :turn_right, no, _rules) do
    {:ok, :turn_right, turn_towards(lm, no, :clockwise)}
  end

  def perform_action(lm, :turn_left, no, _rules) do
    {:ok, :turn_left, turn_towards(lm, no, :anticlockwise)}
  end

  def perform_action(lm, :pick_up, no, rules) do
    {pos, dest, _dir, holding} = find_robot_info(lm, no)
    {tile_type_dest, _v, extra} = get_tile(lm, dest)
    dest_entity = get_entity(lm, dest)

    cond do
      table_like?(tile_type_dest) ->
        case GameRule.pick_up(rules, holding, dest_entity) do
          {:ok, hand_entity, table_entity} ->
            {:ok, {:pick_item, hand_entity, table_entity},
             lm
             |> put_robot_item(pos, hand_entity)
             |> put_entity(dest, table_entity)}

          :error ->
            :error
        end

      tile_type_dest == :source && holding == nil ->
        new_levelmap = put_robot_item(lm, pos, extra.item)
        {:ok, {:pick_source, extra.item}, new_levelmap}

      true ->
        :error
    end
  end

  def perform_action(lm, :put_down, no, rules) do
    {pos, dest, _dir, holding} = find_robot_info(lm, no)
    {tile_type_dest, _v, _extra} = get_tile(lm, dest)
    dest_entity = get_entity(lm, dest)

    cond do
      table_like?(tile_type_dest) ->
        case GameRule.put_down(rules, holding, dest_entity) do
          {:ok, hand_entity, table_entity} ->
            {:ok, {:put_item, hand_entity, table_entity},
             lm
             |> put_robot_item(pos, hand_entity)
             |> put_entity(dest, table_entity)}

          :error ->
            :error
        end

      tile_type_dest == :drain ->
        case holding do
          item = {:item, _, _} ->
            {:ok, {:drained_item, item},
             lm
             |> put_robot_item(pos, nil)
             |> Map.update!(:drain, &[item | &1])}

          {:container, con, item = {:item, _, _}} ->
            remaining = {:container, con, nil}

            {:ok, {:drained_container, item, remaining},
             lm
             |> put_robot_item(pos, remaining)
             |> Map.update!(:drain, &[item | &1])}

          _ ->
            :error
        end

      tile_type_dest == :delivery ->
        case holding do
          {:container, :plate, item = {:item, _, _}} ->
            {:ok, {:delivered, item},
             lm
             |> put_robot_item(pos, {:container, :plate, nil})
             |> Map.update!(:delivery, &[item | &1])}

          _ ->
            :error
        end

      true ->
        :error
    end
  end

  def perform_action(lm, :chop, no, rules) do
    pos = find_robot_pos(lm, no)
    {:robot, ^no, dir, _} = get_entity(lm, pos)
    dest = Math.add(pos, dir)

    with :board <- get_tile_type(lm, dest),
         {:item, item, _stage} <- get_entity(lm, dest),
         {:ok, item} <- GameRule.chop(rules, item) do
      item_entity = {:item, item, 0}
      {:ok, {:chopped, item_entity}, put_entity(lm, dest, item_entity)}
    else
      _ -> :error
    end
  end

  def perform_action(lm, {:increment, value}, no, _rules) do
    {pos, _dest, _dir, holding} = find_robot_info(lm, no)

    case holding do
      {:counter, count, lower_limit, upper_limit} ->
        new_count = Math.clamp(count + value, lower_limit, upper_limit)
        new_levelmap = put_robot_item(lm, pos, {:counter, new_count, lower_limit, upper_limit})
        {:ok, {:counter_value, new_count}, new_levelmap}

      _ ->
        :error
    end
  end

  def perform_action(lm, {:decrement, value}, no, rules) do
    perform_action(lm, {:increment, -value}, no, rules)
  end

  def perform_action(lm, :wait, _no, _rules) do
    {:ok, :wait, lm}
  end

  def check_sensor(lm, {:is_tile, tile}, no, _rules) do
    pos = find_robot_pos(lm, no)
    {:robot, ^no, dir, _holding} = get_entity(lm, pos)
    dest = Math.add(pos, dir)

    case get_tile(lm, dest) do
      {^tile, _variation, _extra} -> true
      _ -> false
    end
  end

  def check_sensor(lm, {:is_item, name}, no, _rules) do
    {_pos, dest, _dir, _holding} = find_robot_info(lm, no)

    case get_entity(lm, dest) do
      {:item, ^name, _} -> true
      {:container, _cname, {:item, ^name, _}} -> true
      _ -> false
    end
  end

  def check_sensor(lm, {:check_counter, op, value}, no, _rules) do
    {_pos, _dest, _dir, holding} = find_robot_info(lm, no)

    case holding do
      {:counter, count, _, _} ->
        compare(op, count, value)

      _ ->
        false
    end
  end

  def update_tile(lm, pos, rules) do
    {tile_type, _, _} = get_tile(lm, pos)
    entity = get_entity(lm, pos)

    case entity do
      {:container, container, {:item, item, stage}} ->
        case GameRule.cook(rules, tile_type, container, item, stage) do
          {:ok, item, stage} ->
            {:ok, put_entity(lm, pos, {:container, container, {:item, item, stage}})}

          :error ->
            :error
        end

      _ ->
        :error
    end
  end

  defp turn_towards(lm, no, tdir) do
    {pos, _dest, dir, holding} = find_robot_info(lm, no)
    new_dir = Robocook.Math.rotate(dir, tdir)

    put_entity(lm, pos, {:robot, no, new_dir, holding})
  end

  defp find_robot_pos(lmap, no) do
    {:ok, pos} =
      Grid.find_index(lmap.entities, fn
        {:robot, ^no, _, _} -> true
        _ -> false
      end)

    pos
  end

  defp find_robot_info(lm, no) do
    pos = find_robot_pos(lm, no)
    {:robot, ^no, dir, holding} = get_entity(lm, pos)
    dest = Math.add(pos, dir)

    {pos, dest, dir, holding}
  end

  defp table_like?(type), do: type in [:table, :board, :stove, :oven, :mixer]

  defp compare(:eq, x, y), do: x == y
  defp compare(:ne, x, y), do: x != y
  defp compare(:gt, x, y), do: x > y
  defp compare(:lt, x, y), do: x < y
  defp compare(:gte, x, y), do: x >= y
  defp compare(:lte, x, y), do: x <= y
end
