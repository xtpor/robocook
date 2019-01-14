defmodule RobocookTest do
  use ExUnit.Case
  doctest Robocook

  test "greets the world" do
    assert Robocook.hello() == :world
  end
end
