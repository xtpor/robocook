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
          | {:counter, count :: integer()}
          | {:decoration, variation :: integer()}
          | {:robot, no :: 0..7, direction, nil | item()}

  def new(size) do
    %{
      tiles: Grid.new(size, :void),
      entities: Grid.new(size),
      drain: [],
      delivery: []
    }
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
      {:ok, lm |> put_entity(pos, nil) |> put_entity(dest, entity)}
    else
      _ -> :error
    end
  end

  def perform_action(lm, :turn_right, no, _rules) do
    turn_towards(lm, no, :clockwise)
  end

  def perform_action(lm, :turn_left, no, _rules) do
    turn_towards(lm, no, :anticlockwise)
  end

  def perform_action(lm, :pick_up, no, rules) do
    pos = find_robot_pos(lm, no)
    {:robot, ^no, dir, holding} = get_entity(lm, pos)

    dest = Robocook.Math.add(pos, dir)
    {tile_type_dest, _v, extra} = get_tile(lm, dest)
    dest_entity = get_entity(lm, dest)

    cond do
      table_like?(tile_type_dest) ->
        case GameRule.pick_up(rules, holding, dest_entity) do
          {:ok, hand_entity, table_entity} ->
            {:ok,
             lm
             |> put_robot_item(pos, hand_entity)
             |> put_entity(dest, table_entity)}

          :error ->
            :error
        end

      tile_type_dest == :source && holding == nil ->
        {:ok, put_entity(lm, pos, {:robot, no, dir, extra.item})}

      true ->
        :error
    end
  end

  def perform_action(lm, :put_down, no, rules) do
    pos = find_robot_pos(lm, no)
    {:robot, ^no, dir, holding} = get_entity(lm, pos)
    dest = Robocook.Math.add(pos, dir)
    {tile_type_dest, _v, _extra} = get_tile(lm, dest)
    dest_entity = get_entity(lm, dest)

    cond do
      table_like?(tile_type_dest) ->
        case GameRule.put_down(rules, holding, dest_entity) do
          {:ok, hand_entity, table_entity} ->
            {:ok,
             lm
             |> put_robot_item(pos, hand_entity)
             |> put_entity(dest, table_entity)}

          :error ->
            :error
        end

      tile_type_dest == :drain ->
        case holding do
          item = {:item, _, _} ->
            {:ok,
             lm
             |> put_robot_item(pos, nil)
             |> Map.update!(:drain, &[item | &1])}

          {:container, con, item = {:item, _, _}} ->
            {:ok,
             lm
             |> put_robot_item(pos, {:container, con, nil})
             |> Map.update!(:drain, &[item | &1])}

          _ ->
            nil
        end

      tile_type_dest == :delivery ->
        case holding do
          {:container, :plate, item = {:item, _, _}} ->
            {:ok,
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
      {:ok, put_entity(lm, dest, {:item, item, 0})}
    else
      _ -> :error
    end
  end

  def perform_action(lm, :wait, _no, _rules) do
    {:ok, lm}
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
    pos = find_robot_pos(lm, no)
    {:robot, ^no, dir, holding} = get_entity(lm, pos)
    new_dir = Robocook.Math.rotate(dir, tdir)
    {:ok, put_entity(lm, pos, {:robot, no, new_dir, holding})}
  end

  defp find_robot_pos(lmap, no) do
    IO.inspect({:find_robot_pos, no})
    {:ok, pos} =
      Grid.find_index(lmap.entities, fn
        {:robot, ^no, _, _} -> true
        _ -> false
      end)

    pos
  end

  defp table_like?(type), do: type in [:table, :board, :stove, :oven, :mixer]
end
