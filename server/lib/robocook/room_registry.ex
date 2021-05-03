defmodule Robocook.RoomRegistry do
  use GenServer

  @square_total 16
  @square_required 4
  @max_attempts 10

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(pid \\ self()) do
    GenServer.call(__MODULE__, {:register, pid})
  end

  def unregister(pid \\ self()) do
    GenServer.cast(__MODULE__, {:unregister, pid})
  end

  def lookup(room_id) do
    GenServer.call(__MODULE__, {:lookup, room_id})
  end

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:register, pid}, _from, mapping) do
    case generate_id_for(mapping, @max_attempts) do
      {:ok, id} ->
        new_mapping =
          mapping
          |> Map.put(pid, id)
          |> Map.put(id, pid)

        Process.monitor(pid)
        {:reply, {:ok, id}, new_mapping}

      :error ->
        {:reply, :error, mapping}
    end
  end

  @impl true
  def handle_call({:lookup, room_id}, _from, mapping) do
    {:reply, Map.fetch(mapping, room_id), mapping}
  end

  @impl true
  def handle_cast({:unregister, pid}, mapping) do
    {:noreply, unmap(mapping, pid)}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, mapping) do
    if Map.has_key?(mapping, pid) do
      {:noreply, unmap(mapping, pid)}
    else
      {:noreply, mapping}
    end
  end

  def generate_id do
    generate_loop([]) |> Enum.sort()
  end

  defp unmap(mapping, pid) do
    id = Map.fetch!(mapping, pid)
    mapping |> Map.delete(pid) |> Map.delete(id)
  end

  defp generate_id_for(_mapping, 0) do
    :error
  end

  defp generate_id_for(mapping, attempts) do
    id = generate_id()

    case Map.fetch(mapping, id) do
      {:ok, _} -> generate_id_for(mapping, attempts - 1)
      :error -> {:ok, id}
    end
  end

  defp generate_loop(list) when length(list) == @square_required do
    list
  end

  defp generate_loop(list) do
    number = Enum.random(0..(@square_total - 1))

    if number in list do
      generate_loop(list)
    else
      generate_loop([number | list])
    end
  end
end
