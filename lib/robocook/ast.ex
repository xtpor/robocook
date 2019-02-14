defmodule Robocook.Ast do
  # internal abstract syntax tree format

  @type ast :: [procedure, ...]
  @type procedure :: {:procedure, name :: non_neg_integer(), [statement]}

  @type statement ::
          {:action, action()}
          | {:call, name :: non_neg_integer()}
          | {:if, condition(), [statement()], [statement()]}
          | {:loop, [statement()]}
          | {:while, condition(), [statement()]}
          | {:repeat, count :: non_neg_integer(), [statement()]}
          | :halt

  @type action ::
          :move_forward
          | :turn_left
          | :turn_right
          | :pick_up
          | :put_down
          | :chop
          | {:increment, integer()}
          | {:decrement, integer()}
          | :wait

  @type condition ::
          {:not, condition()}
          | {:and, condition(), condition()}
          | {:or, condition(), condition()}
          | {:const, true | false}

  @max_proc 100

  def size(ast) do
    ast
    |> Enum.map(fn {:procedure, _, body} -> ast_fragment_size(body) end)
    |> Enum.sum()
  end

  defp ast_fragment_size([]) do
    0
  end

  defp ast_fragment_size([{:action, _} | rest]) do
    1 + ast_fragment_size(rest)
  end

  defp ast_fragment_size([{:call, _} | rest]) do
    1 + ast_fragment_size(rest)
  end

  defp ast_fragment_size([{:if, _, tb, fb} | rest]) do
    1 + ast_fragment_size(tb) + ast_fragment_size(fb) + ast_fragment_size(rest)
  end

  defp ast_fragment_size([{:loop, b} | rest]) do
    1 + ast_fragment_size(b) + ast_fragment_size(rest)
  end

  defp ast_fragment_size([{:while, _, b} | rest]) do
    1 + ast_fragment_size(b) + ast_fragment_size(rest)
  end

  defp ast_fragment_size([{:repeat, _, b} | rest]) do
    1 + ast_fragment_size(b) + ast_fragment_size(rest)
  end

  defp ast_fragment_size([:halt | rest]) do
    1 + ast_fragment_size(rest)
  end

  def deserialize(sexp) do
    Enum.map(sexp, &deserialize_toplevel/1)
  end

  def deserialize_toplevel(["procedure", name, stmts]) when name in 0..(@max_proc - 1) do
    {:procedure, name, deserialize_statements(stmts)}
  end

  def deserialize_statements(stmts) do
    Enum.map(stmts, &deserialize_statement/1)
  end

  def deserialize_statement(["action", name]) do
    {:action, deserialize_action(name)}
  end

  def deserialize_statement(["call", name]) when name in 1..(@max_proc - 1) do
    {:call, name}
  end

  def deserialize_statement(["if", condi, pt, pf]) do
    {:if, deserialize_condition(condi), deserialize_statements(pt), deserialize_statements(pf)}
  end

  def deserialize_statement(["loop", stmts]) do
    {:loop, deserialize_statements(stmts)}
  end

  def deserialize_statement(["while", condi, stmts]) do
    {:while, deserialize_condition(condi), deserialize_statements(stmts)}
  end

  def deserialize_statement(["repeat", count, stmts]) do
    {:repeat, count, deserialize_statements(stmts)}
  end

  def deserialize_statement(["halt"]) do
    :halt
  end

  def deserialize_action("move_forward"), do: :move_forward
  def deserialize_action("turn_left"), do: :turn_left
  def deserialize_action("turn_right"), do: :turn_right
  def deserialize_action("pick_up"), do: :pick_up
  def deserialize_action("put_down"), do: :put_down
  def deserialize_action("chop"), do: :chop
  def deserialize_action(["increment", n]) when is_integer(n), do: {:increment, n}
  def deserialize_action(["decrement", n]) when is_integer(n), do: {:decrement, n}
  def deserialize_action("wait"), do: :wait

  def deserialize_condition(["const", bool]) when is_boolean(bool) do
    {:const, bool}
  end

  def deserialize_condition(["not", condi]) do
    {:not, deserialize_condition(condi)}
  end

  def deserialize_condition(["and", cond1, cond2]) do
    {:and, deserialize_condition(cond1), deserialize_condition(cond2)}
  end

  def deserialize_condition(["or", cond1, cond2]) do
    {:or, deserialize_condition(cond1), deserialize_condition(cond2)}
  end

  def deserialize_condition(["test", ["is_item", name]]) when is_binary(name) do
    {:test, {:is_item, String.to_existing_atom(name)}}
  end

  def deserialize_condition(["test", ["is_tile", name]]) when is_binary(name) do
    {:test, {:is_tile, String.to_existing_atom(name)}}
  end

  def deserialize_condition(["test", ["check_counter", op, value]])
      when op in ["eq", "ne", "gt", "lt", "gte", "lte"] and is_integer(value) do
    {:test, {:check_counter, String.to_existing_atom(op), value}}
  end

  #

  def serialize(ast) do
    Enum.map(ast, &serialize_toplevel/1)
  end

  def serialize_toplevel({:procedure, name, stmts}) do
    ["procedure", name, serialize_statements(stmts)]
  end

  def serialize_statements(stmts) do
    Enum.map(stmts, &serialize_statement/1)
  end

  def serialize_statement({:action, act}) do
    ["action", serialize_action(act)]
  end

  def serialize_statement({:call, name}) do
    ["call", name]
  end

  def serialize_statement({:if, condi, pt, pf}) do
    ["if", serialize_condition(condi), serialize_statements(pt), serialize_statements(pf)]
  end

  def serialize_statement({:loop, stmts}) do
    ["loop", serialize_statements(stmts)]
  end

  def serialize_statement({:while, condi, stmts}) do
    ["while", serialize_condition(condi), serialize_statements(stmts)]
  end

  def serialize_statement({:repeat, count, stmts}) do
    ["repeat", count, serialize_statements(stmts)]
  end

  def serialize_statement(:halt) do
    ["halt"]
  end

  def serialize_action(:move_forward), do: "move_forward"
  def serialize_action(:turn_left), do: "turn_left"
  def serialize_action(:turn_right), do: "turn_right"
  def serialize_action(:pick_up), do: "pick_up"
  def serialize_action(:put_down), do: "put_down"
  def serialize_action(:chop), do: "chop"
  def serialize_action({:increment, n}), do: ["increment", n]
  def serialize_action({:decrement, n}), do: ["decrement", n]
  def serialize_action(:wait), do: "wait"

  def serialize_condition({:const, bool}) do
    ["const", bool]
  end

  def serialize_condition({:not, condi}) do
    ["not", serialize_condition(condi)]
  end

  def serialize_condition({:and, cond1, cond2}) do
    ["and", serialize_condition(cond1), serialize_condition(cond2)]
  end

  def serialize_condition({:or, cond1, cond2}) do
    ["or", serialize_condition(cond1), serialize_condition(cond2)]
  end

  def serialize_condition({:test, {:is_item, name}}) do
    ["test", ["is_item", name]]
  end

  def serialize_condition({:test, {:is_tile, name}}) do
    ["test", ["is_tile", name]]
  end

  def serialize_condition({:test, {:check_counter, op, value}}) do
    ["test", ["check_counter", op, value]]
  end
end
