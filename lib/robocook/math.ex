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

  def clamp(value, _, upper) when value >= upper, do: upper
  def clamp(value, lower, _) when value <= lower, do: lower
  def clamp(value, _lower, _upper), do: value
end
