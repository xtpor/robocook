defmodule Robocook.Compiler do
  # internal abstract syntax tree format

  @type ast :: [procedure, ...]
  @type procedure :: {:procedure, name :: non_neg_integer(), [statement]}
  @type condition :: term()

  @type statement ::
          {:action, atom()}
          | {:callsub, name :: non_neg_integer()}
          | {:if, condition(), [statement()], [statement()]}
          | {:loop, [statement()]}
          | {:while, condition(), [statement()]}
          | {:repeat, count :: non_neg_integer(), [statement()]}
          | :halt

  def compile(sexp) do
    Enum.map(sexp, &compile_toplevel/1)
  end

  def compile_toplevel(["program", name, stmts]) when is_binary(name) do
    {:program, name, compile_statements(stmts)}
  end

  def compile_toplevel(["subprogram", name, stmts]) when is_binary(name) do
    {:subprogram, name, compile_statements(stmts)}
  end

  def compile_statements(stmts) do
    Enum.map(stmts, &compile_statement/1)
  end

  def compile_statement(["action", name]) when is_binary(name) do
    {:action, name}
  end

  def compile_statement(["if", condi, pt]) do
    {:if, compile_condition(condi), compile_statements(pt)}
  end

  def compile_statement(["if", condi, pt, pf]) do
    {:if, compile_condition(condi), compile_statements(pt), compile_statements(pf)}
  end

  def compile_statement(["repeat", count, stmts]) do
    {:repeat, count, compile_statements(stmts)}
  end

  def compile_statement(["loop", stmts]) do
    {:loop, compile_statements(stmts)}
  end

  def compile_statement(["while", condi, stmts]) do
    {:while, compile_condition(condi), compile_statements(stmts)}
  end

  def compile_statement(["callsub", name]) when is_binary(name) do
    {:callsub, name}
  end

  def compile_condition(["not", condi]) do
    {:not, compile_condition(condi)}
  end

  def compile_condition(["and", cond1, cond2]) do
    {:and, compile_condition(cond1), compile_condition(cond2)}
  end

  def compile_condition(["or", cond1, cond2]) do
    {:or, cond1, cond2}
  end

  def compile_condition(["is-facing", dir]) when is_binary(dir) do
    {:is_facing, dir}
  end

  def compile_condition(["test-item", item]) when is_binary(item) do
    {:test_item, item}
  end
end
