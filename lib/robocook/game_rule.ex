defmodule Robocook.GameRule do
  @type food_item :: atom()
  @type stage :: non_neg_integer()
  @type container :: :plate | :pan | :pot | :bowl
  @type context :: container() | nil
  @type tile ::
          :void
          | :floor
          | :wall
          | :table
          | :drain
          | :source
          | :delivery
          | :board
          | :stove
          | :oven
          | :mixer
          | :display

  @type rule ::
          {:chop, food_item, food_item}
          | {:craft, context, food_item, food_item, food_item}
          | {:cook, tile, container, food_item, food_item, stage}
          | {:put_in, container, food_item}
          | {:pick_from, container, food_item}

  @opaque t :: [rule]

  def new(rules) do
    rules
  end

  def append(rules, rule) do
    rules ++ [rule]
  end

  def prepend(rules, rule) do
    [rule] ++ rules
  end

  def craft(rules, context, name1, name2) do
    Enum.find_value(rules, :error, fn
      {:craft, ^context, ^name1, ^name2, to} -> {:ok, to}
      {:craft, ^context, ^name2, ^name1, to} -> {:ok, to}
      _ -> false
    end)
  end

  @spec chop(t, food_item) :: {:ok, food_item} | :error
  def chop(rules, name) do
    Enum.find_value(rules, :error, fn
      {:chop, ^name, to} -> {:ok, to}
      _ -> false
    end)
  end

  @spec cook(t, tile(), container(), food_item(), stage()) :: {:ok, food_item(), stage()} | :error
  def cook(rules, tile, container, ingredient, stage) do
    Enum.find_value(rules, :error, fn
      {:cook, ^tile, ^container, ^ingredient, result, slimit} ->
        case stage + 1 >= slimit do
          true -> {:ok, result, 0}
          false -> {:ok, ingredient, stage + 1}
        end

      _ ->
        false
    end)
  end

  def can_put_in?(rules, c, i) do
    Enum.any?(rules, fn
      {:put_in, ^c, ^i} -> true
      _ -> false
    end)
  end

  def can_pick_from?(rules, c, i) do
    Enum.any?(rules, fn
      {:pick_from, ^c, ^i} -> true
      _ -> false
    end)
  end

  def pick_up(_rules, nil, ing = {:item, _, _}) do
    {:ok, ing, nil}
  end

  def pick_up(_rules, nil, con = {:container, _, _}) do
    {:ok, con, nil}
  end

  def pick_up(rules, {:container, c1, nil}, {:container, c2, {:item, i2, s}}) do
    case can_pick_from?(rules, c2, i2) && can_put_in?(rules, c1, i2) do
      true -> {:ok, {:container, c1, {:item, i2, s}}, {:container, c2, nil}}
      false -> :error
    end
  end

  def pick_up(rules, {:container, c1, ing1}, {:container, c2, ing2})
      when ing1 != nil and ing2 != nil do
    {:item, i1, _s1} = ing1
    {:item, i2, _s2} = ing2

    case can_pick_from?(rules, c1, i2) && can_put_in?(rules, c1, i2) do
      true ->
        case craft(rules, c1, i1, i2) do
          {:ok, r} -> {:ok, {:container, c1, {:item, r, 0}}, {:container, c2, nil}}
          :error -> :error
        end

      false ->
        :error
    end
  end

  def pick_up(_rules, _, _) do
    :error
  end

  def put_down(_rules, item = {:item, _, _}, nil) do
    {:ok, nil, item}
  end

  def put_down(_rules, con = {:container, _, _}, nil) do
    {:ok, nil, con}
  end

  def put_down(rules, {:item, i1, _s1}, {:item, i2, _s2}) do
    case craft(rules, nil, i1, i2) do
      {:ok, r} -> {:ok, nil, {:item, r, 0}}
      :error -> :error
    end
  end

  def put_down(rules, item = {:item, i1, _s1}, {:container, c1, nil}) do
    if can_put_in?(rules, c1, i1) do
      {:ok, nil, {:container, c1, item}}
    else
      :error
    end
  end

  def put_down(rules, con = {:container, _, nil}, item = {:item, _, _}) do
    put_down(rules, item, con)
  end

  def put_down(rules, {:item, i1, _s1}, {:container, c2, {:item, i2, _}}) do
    if can_put_in?(rules, c2, i1) do
      case craft(rules, c2, i1, i2) do
        {:ok, r} -> {:ok, nil, {:container, c2, {:item, r, 0}}}
        :error -> :error
      end
    else
      :error
    end
  end

  def put_down(rules, con = {:container, _, {:item, _, _}}, item = {:item, _, _}) do
    put_down(rules, item, con)
  end

  def put_down(rules, {:container, c1, {:item, i1, s1}}, {:container, c2, nil}) do
    if can_put_in?(rules, c2, i1) do
      {:ok, {:container, c1, nil}, {:container, c2, {:item, i1, s1}}}
    else
      :error
    end
  end

  def put_down(rules, {:container, c1, {:item, i1, _}}, {:container, c2, {:item, i2, _}}) do
    if can_put_in?(rules, c2, i1) do
      case craft(rules, c2, i1, i2) do
        {:ok, r} -> {:ok, {:container, c1, nil}, {:container, c2, {:item, r, 0}}}
        :error -> :error
      end
    else
      :error
    end
  end

  def put_down(_rules, _, _) do
    :error
  end
end
