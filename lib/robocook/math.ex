defmodule Robocook.Math do
  def add({x0, y0}, {x1, y1}) do
    {x0 + x1, y0 + y1}
  end

  def rotate({x, y}, :clockwise) do
    {-y, x}
  end

  def rotate({x, y}, :anticlockwise) do
    {y, -x}
  end
end
