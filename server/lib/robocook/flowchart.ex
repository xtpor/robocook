defmodule Robocook.Flowchart do
  def new do
    %{size: 0}
  end

  def size(%{size: s}) do
    s
  end

  def insert(chart = %{size: s}, item) do
    new_chart =
      chart
      |> Map.update!(:size, &(&1 + 1))
      |> Map.put(s, item)

    {s, new_chart}
  end

  def replace(chart, id, item) do
    Map.update!(chart, id, fn _ -> item end)
  end

  def first_node(chart) do
    chart.size - 1
  end

  def get(chart, id) do
    chart[id]
  end

  def from_ast(ast) do
    Enum.reduce(ast, %{}, fn {:procedure, name, stmts}, charts ->
      Map.put(charts, name, convert_statements(stmts))
    end)
  end

  @doc false
  def convert_statements(ast_statements) do
    chart = new()
    {end_node, chart} = insert(chart, {:end, %{}})
    {node_begin, chart} = convert_statement(chart, ast_statements, end_node, 0)
    {_, chart} = insert(chart, {:start, %{next: node_begin}})
    chart
  end

  @doc false
  def convert_statement(chart, [], end_node, _depth) do
    {end_node, chart}
  end

  def convert_statement(chart, [:halt | rest], end_node, depth) do
    {_, chart} = convert_statement(chart, rest, end_node, depth)
    insert(chart, {:halt, %{}})
  end

  def convert_statement(chart, [{:action, a} | rest], end_node, depth) do
    {next_node, chart} = convert_statement(chart, rest, end_node, depth)
    insert(chart, {:action, %{action: a, next: next_node}})
  end

  def convert_statement(chart, [{:call, s} | rest], end_node, depth) do
    {next_node, chart} = convert_statement(chart, rest, end_node, depth)
    insert(chart, {:call, %{proc: s, next: next_node}})
  end

  def convert_statement(chart, [{:if, c, t, f} | rest], end_node, depth) do
    {nnode, chart} = convert_statement(chart, rest, end_node, depth)
    {tnode, chart} = convert_statement(chart, t, nnode, depth + 1)
    {fnode, chart} = convert_statement(chart, f, nnode, depth + 1)
    insert(chart, {:decision, %{cond: c, next_t: tnode, next_f: fnode}})
  end

  def convert_statement(chart, [{:loop, body} | rest], end_node, depth) do
    {nnode, chart} = insert(chart, nil)
    {tnode, chart} = convert_statement(chart, body, nnode, depth + 1)
    {fnode, chart} = convert_statement(chart, rest, end_node, depth)

    chart =
      replace(chart, nnode, {:decision, %{cond: {:const, true}, next_t: tnode, next_f: fnode}})

    {nnode, chart}
  end

  def convert_statement(chart, [{:repeat, count, body} | rest], end_node, depth) do
    variable = depth

    {node1, chart} = insert(chart, nil)
    {node2, chart} = insert(chart, nil)
    {node3, chart} = insert(chart, nil)
    {tnode, chart} = convert_statement(chart, body, node3, depth + 1)
    {fnode, chart} = convert_statement(chart, rest, end_node, depth)

    chart =
      chart
      |> replace(node1, {:v_set, %{var: variable, val: 0, next: node2}})
      |> replace(node2, {:v_check, %{var: variable, val: count, next_t: tnode, next_f: fnode}})
      |> replace(node3, {:v_incr, %{var: variable, val: 1, next: node2}})

    {node1, chart}
  end

  def convert_statement(chart, [{:while, condi, body} | rest], end_node, depth) do
    {node, chart} = insert(chart, nil)
    {tnode, chart} = convert_statement(chart, body, node, depth + 1)
    {fnode, chart} = convert_statement(chart, rest, end_node, depth)

    chart = replace(chart, node, {:decision, %{cond: condi, next_t: tnode, next_f: fnode}})

    {node, chart}
  end
end
