defmodule Robocook.Interpreter do
  alias Robocook.Flowchart

  @stack_limit 100
  @instruction_limit 250

  def new(ast) do
    charts = Flowchart.from_ast(ast)

    %{
      flowcharts: charts,
      stack: [%{proc: 0, pc: Flowchart.first_node(charts[0]), locals: %{}}],
      counter: 0
    }
  end

  def step(interp) do
    cond do
      terminated?(interp) ->
        {:error, :terminated, interp}

      interp.counter >= @instruction_limit ->
        {:error, :instruction_limit, %{interp | stack: []}}

      true ->
        interp = increment_counter(interp)
        %{flowcharts: charts, stack: stack} = interp
        [%{proc: chart, pc: node} | _] = stack

        case Flowchart.get(charts[chart], node) do
          {:start, %{next: next}} ->
            {:ok, set_pc(interp, next)}

          {:end, %{}} ->
            {:ok, dealloc_frame(interp)}

          {:halt, %{}} ->
            {:error, :halted, %{interp | stack: []}}

          {:action, %{action: action, next: next}} ->
            {:yield, action, interp |> reset_counter() |> set_pc(next)}

          {:call, %{proc: next_proc, next: next}} ->
            if length(stack) >= @stack_limit do
              {:error, :stack_limit, %{interp | stack: []}}
            else
              {:ok, interp |> set_pc(next) |> alloc_frame(next_proc)}
            end

          {:decision, %{cond: condition, next_t: next_t, next_f: next_f}} ->
            handle_decision_result(interp, next_t, next_f, check(condition))

          {:v_set, %{var: var, val: val, next: next}} ->
            {:ok, interp |> set_pc(next) |> set_local(var, val)}

          {:v_check, %{var: var, val: val, next_t: next_t, next_f: next_f}} ->
            if get_local(interp, var) < val do
              {:ok, set_pc(interp, next_t)}
            else
              {:ok, set_pc(interp, next_f)}
            end

          {:v_incr, %{var: var, val: val, next: next}} ->
            new_val = get_local(interp, var) + val
            {:ok, interp |> set_pc(next) |> set_local(var, new_val)}
        end
    end
  end

  def step_continue({interp, next_t, next_f, cont}, result) do
    handle_decision_result(interp, next_t, next_f, check_continue(cont, result))
  end

  def terminated?(%{stack: []}), do: true
  def terminated?(%{stack: _}), do: false

  defp handle_decision_result(interp, next_t, next_f, call_result) do
    case call_result do
      {:continue, req, cont} ->
        {:continue, req, {interp, next_t, next_f, cont}}

      {:done, true} ->
        {:ok, set_pc(interp, next_t)}

      {:done, false} ->
        {:ok, set_pc(interp, next_f)}
    end
  end

  defp set_pc(interp, pc) do
    [top | rest] = interp.stack
    %{interp | stack: [%{top | pc: pc} | rest]}
  end

  defp reset_counter(interp) do
    %{interp | counter: 0}
  end

  defp increment_counter(interp) do
    %{interp | counter: interp.counter + 1}
  end

  defp set_local(interp, var, val) do
    [top | rest] = interp.stack
    new_locals = Map.put(top.locals, var, val)
    %{interp | stack: [%{top | locals: new_locals} | rest]}
  end

  defp get_local(interp, var) do
    %{stack: [%{locals: locals} | _rest]} = interp
    locals[var]
  end

  defp alloc_frame(interp, proc) do
    pc = Flowchart.first_node(interp.flowcharts[proc])
    Map.update!(interp, :stack, &[%{proc: proc, pc: pc, locals: %{}} | &1])
  end

  defp dealloc_frame(interp) do
    Map.update!(interp, :stack, fn [_discarded | rest] -> rest end)
  end

  def check({:const, value}), do: {:done, value}
  def check({:test, test}), do: {:continue, test, nil}
  def check({:not, c1}), do: handle_not(check(c1))
  def check({:and, c1, c2}), do: handle_and(check(c1), c2)
  def check({:or, c1, c2}), do: handle_or(check(c1), c2)

  def check_continue(nil, r), do: {:done, r}
  def check_continue({:and, ct, c2}, r), do: handle_and(check_continue(ct, r), c2)
  def check_continue({:or, ct, c2}, r), do: handle_or(check_continue(ct, r), c2)
  def check_continue({:not, ct}, r), do: handle_not(check_continue(ct, r))

  defp handle_and({:continue, t, ct}, c2), do: {:continue, t, {:and, ct, c2}}
  defp handle_and({:done, true}, c2), do: check(c2)
  defp handle_and({:done, false}, _c2), do: {:done, false}

  defp handle_or({:continue, t, ct}, c2), do: {:continue, t, {:or, ct, c2}}
  defp handle_or({:done, true}, _c2), do: {:done, true}
  defp handle_or({:done, false}, c2), do: check(c2)

  defp handle_not({:continue, t, ct}), do: {:continue, t, {:not, ct}}
  defp handle_not({:done, value}), do: {:done, not value}
end
