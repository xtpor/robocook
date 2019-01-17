defmodule Robocook.Grid do
  # Generic grid data structure

  @opaque t :: map()
  @type index :: {non_neg_integer(), non_neg_integer()}

  @spec new(index, term()) :: t
  def new(size = {_w, _h}, default \\ nil) do
    %{size: size, items: %{}, default: default}
  end

  @spec get(t, index) :: term()
  def get!(grid, pt = {_, _}) do
    {:ok, value} = fetch(grid, pt)
    value
  end

  @spec get(t, index, term()) :: term()
  def get(grid, pt = {_, _}, default \\ nil) do
    case fetch(grid, pt) do
      {:ok, value} -> value
      :error -> default
    end
  end

  @spec fetch(t, index) :: {:ok, term()} | :error
  def fetch(grid, pt = {_, _}) do
    case within?(grid, pt) do
      true -> {:ok, Map.get(grid.items, pt, grid.default)}
      false -> :error
    end
  end

  @spec put!(t, index, term()) :: t
  def put!(grid, pt = {_, _}, value) do
    true = within?(grid, pt)
    Map.update!(grid, :items, fn items -> Map.put(items, pt, value) end)
  end

  @spec size(t) :: index
  def size(grid) do
    grid.size
  end

  @spec within?(t, index) :: boolean()
  def within?(grid, {x, y}) do
    {sx, sy} = size(grid)
    0 <= x && x < sx && 0 <= y && y < sy
  end

  @spec find_index(t, fun()) :: {:ok, index} | :error
  def find_index(grid, predicate) do
    {sx, sy} = size(grid)

    for i <- 0..(sx - 1), j <- 0..(sy - 1) do
      {i, j}
    end
    |> Enum.reduce(:error, fn
      pt, :error ->
        case grid |> get!(pt) |> predicate.() do
          true -> {:ok, pt}
          false -> :error
        end

      _, {:ok, value} ->
        {:ok, value}
    end)
  end
end
