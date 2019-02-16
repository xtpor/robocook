defmodule Robocook.Players do

  def at([{_pid, name} | _], 0), do: {:ok, name}
  def at([nil | _], 0), do: :error
  def at([_ | rest], i), do: at(rest, i - 1)

  def lookup([{pid, name} | _players], pid), do: {:ok, name}
  def lookup([_head | rest], pid), do: lookup(rest, pid)
  def lookup([], _pid), do: :error

  def size(players) do
    Enum.filter(players, &(&1 != nil)) |> length
  end

  def capacity(players) do
    length(players)
  end

  def full?(players) do
    Enum.all?(players, &(&1 != nil))
  end

  def has?([{_pid, name} | _], name), do: true
  def has?([_ | rest], name), do: has?(rest, name)
  def has?([], _name), do: false

  def remove([{_pid, name} | rest], name) do
    rest ++ [nil]
  end

  def remove([head | rest], pid) do
    [head | remove(rest, pid)]
  end

  def add([], _entry) do
    :error
  end

  def add([nil | rest], entry) do
    {:ok, [entry | rest]}
  end

  def add([p | rest], entry) do
    case add(rest, entry) do
      {:ok, new_rest} -> {:ok, [p | new_rest]}
      :error -> :error
    end
  end

  def delete([{_pid, name} | rest], name) do
    [nil | rest]
  end

  def delete([head | tail], name) do
    [head | delete(tail, name)]
  end

  def monitor(players) do
    each(players, fn pid, _, _ -> Process.monitor(pid) end)
  end

  def notify_all(players, msg) do
    each(players, fn pid, _, _ -> send(pid, msg) end)
  end

  def notify_each(players, msg_func) do
    each(players, fn pid, _, index -> send(pid, msg_func.(index)) end)
  end

  defp each(players, func) do
    players
    |> Enum.with_index()
    |> Enum.each(fn
      {{pid, name}, index} -> func.(pid, name, index)
      {nil, _index} -> nil
    end)
  end
end
