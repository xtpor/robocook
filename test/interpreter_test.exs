defmodule InterpreterTest do
  alias Robocook.Interpreter
  use ExUnit.Case

  def run_until_terminated(interp) do
    case Interpreter.terminated?(interp) do
      true ->
        []

      false ->
        case Interpreter.step(interp) do
          {:ok, interp} -> run_until_terminated(interp)
          {:yield, action, interp} -> [action | run_until_terminated(interp)]
          {:error, error, interp} -> [error | run_until_terminated(interp)]
        end
    end
  end

  test "move forward 3 steps" do
    program = [
      {:procedure, 0,
       [
         {:action, :move_forward},
         {:action, :move_forward},
         {:action, :move_forward}
       ]}
    ]

    interp = Interpreter.new(program)
    {:ok, interp} = Interpreter.step(interp)
    {:yield, :move_forward, interp} = Interpreter.step(interp)
    {:yield, :move_forward, interp} = Interpreter.step(interp)
    {:yield, :move_forward, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    assert Interpreter.terminated?(interp) == true
  end

  test "turn right repeat 5 times" do
    program = [
      {:procedure, 0,
       [
         {:repeat, 5, [
           {:action, :turn_right}
           ]}
       ]}
    ]

    interp = Interpreter.new(program)
    {:ok, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:yield, :turn_right, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:yield, :turn_right, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:yield, :turn_right, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:yield, :turn_right, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:yield, :turn_right, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step(interp)
    assert Interpreter.terminated?(interp) == true
  end

  test "nested repeat 2 levels" do
    program = [
      {:procedure, 0, [
        {:repeat, 2, [
          {:repeat, 3, [
            {:action, :move_forward}
          ]}
        ]}
      ]}
    ]

    interp = Interpreter.new(program)
    actions = run_until_terminated(interp)
    assert actions == List.duplicate(:move_forward, 6)
  end

  test "nested repeat 3 levels" do
    program = [
      {:procedure, 0, [
        {:repeat, 2, [
          {:repeat, 3, [
            {:repeat, 4, [
              {:action, :move_forward}
            ]}
          ]}
        ]}
      ]}
    ]

    interp = Interpreter.new(program)
    actions = run_until_terminated(interp)
    assert actions == List.duplicate(:move_forward, 2 * 3 * 4)
  end

  test "basic while loop" do
    program = [
      {:procedure, 0,
       [
         {:while, {:not, {:test, {:is_tile, :wall}}}, [
           {:action, :move_forward}
           ]}
       ]}
    ]

    interp = Interpreter.new(program)
    {:ok, interp} = Interpreter.step(interp)
    {:continue, {:is_tile, :wall}, cont} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step_continue(cont, false)
    {:yield, :move_forward, interp} = Interpreter.step(interp)

    {:continue, {:is_tile, :wall}, cont} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step_continue(cont, false)
    {:yield, :move_forward, interp} = Interpreter.step(interp)

    {:continue, {:is_tile, :wall}, cont} = Interpreter.step(interp)
    {:ok, interp} = Interpreter.step_continue(cont, true)
    {:ok, interp} = Interpreter.step(interp)
    assert Interpreter.terminated?(interp) == true
  end

  test "call a simple procedure" do
    program = [
      {:procedure, 0, [
        {:action, :turn_left},
        {:call, 1},
        {:action, :turn_right}
      ]},

      {:procedure, 1, [
        {:action, :move_forward},
        {:action, :move_forward}
      ]}
    ]

    interp = Interpreter.new(program)
    actions = run_until_terminated(interp)
    assert actions == [:turn_left, :move_forward, :move_forward, :turn_right]
  end

  test "infinite loop detection" do
    program = [
      {:procedure, 0, [
        {:while, {:const, true}, []},
        {:action, :move_forward}
      ]}
    ]

    interp = Interpreter.new(program)
    events = run_until_terminated(interp)
    assert events == [:instruction_limit]
  end

  test "too deep nested loop detection" do
    program = [
      {:procedure, 0, [
        {:repeat, 10, [
          {:repeat, 10, [
            {:repeat, 10, [
            ]}
          ]}
        ]},
      ]}
    ]

    interp = Interpreter.new(program)
    events = run_until_terminated(interp)
    assert events == [:instruction_limit]
  end

  test "stack overflow detection" do
    program = [
      {:procedure, 0, [
        {:call, 1}
      ]},

      {:procedure, 1, [
        {:call, 1}
      ]}
    ]

    interp = Interpreter.new(program)
    events = run_until_terminated(interp)
    assert events == [:stack_limit]
  end
end
