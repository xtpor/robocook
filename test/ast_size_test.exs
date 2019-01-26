defmodule AstSizeTest do
  use ExUnit.Case

  test "empty program" do
    program = [
      {:procedure, 0, []}
    ]

    assert Robocook.Compiler.ast_size(program) == 0
  end

  test "3 move forwards" do
    program = [
      {:procedure, 0,
       [
         {:action, :move_forward},
         {:action, :move_forward},
         {:action, :move_forward}
       ]}
    ]

    assert Robocook.Compiler.ast_size(program) == 3
  end

  test "nested repeat loop" do
    program = [
      {:procedure, 0,
       [
         {:action, :move_forward},
         {:loop,
          [
            {:action, :move_forward},
            {:loop,
             [
               {:action, :move_forward}
             ]}
          ]},
         {:action, :move_forward}
       ]}
    ]

    assert Robocook.Compiler.ast_size(program) == 6
  end

  test "if with 2 branches" do
    program = [
      {:procedure, 0,
       [
         {:action, :move_forward},
         {:if, {:test, {:is_tile, :wall}},
          [
            {:action, :move_forward},
            {:action, :move_forward}
          ],
          [
            {:action, :turn_right}
          ]},
         {:action, :move_forward},
         {:action, :move_forward}
       ]}
    ]

    assert Robocook.Compiler.ast_size(program) == 7
  end

  test "2 procedures" do
    program = [
      {:procedure, 0,
       [
         {:action, :move_forward},
         {:action, :move_forward}
       ]},
      {:procedure, 1,
       [
         {:action, :move_forward}
       ]}
    ]

    assert Robocook.Compiler.ast_size(program) == 3
  end
end
