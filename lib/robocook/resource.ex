defmodule Robocook.Resource do
  use GenServer

  @table_name __MODULE__

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def put(resource) do
    GenServer.call(__MODULE__, {:put, resource})
  end

  def get!(ref) do
    {:ok, res} = get(ref)
    res
  end

  def get(ref) do
    case :ets.lookup(@table_name, ref) do
      [{^ref, res}] -> {:ok, res}
      [] -> :error
    end
  end

  def find_by_type(type) do
    @table_name
    |> :ets.select([{{:_, %{type: type}}, [], [:"$_"]}])
    |> Enum.map(fn {_, res} -> res end)
  end

  @impl true
  def init(_args) do
    :ets.new(@table_name, [:named_table, :protected, read_concurrency: true])
    {:ok, nil}
  end

  @impl true
  def handle_call({:put, resource}, _from, nil) do
    :ets.insert(@table_name, {resource.ref, resource})
    {:reply, :ok, nil}
  end
end
