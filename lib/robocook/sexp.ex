defmodule Robocook.SExp do
  def parse(text) do
    tokens = tokenize(text)

    case valid_tokens?(tokens) do
      true -> {:ok, parse_iter(tokens, [[]])}
      false -> :error
    end
  end

  def parse!(text) do
    {:ok, res} = parse(text)
    res
  end

  defp tokenize(text) do
    Regex.scan(~r/(\(|\)|[\w-]+|\s+)/, text, capture: :first)
    |> List.flatten()
    |> Enum.reject(&Regex.match?(~r/\s+/, &1))
  end

  defp valid_tokens?(tokens), do: valid_tokens?(tokens, 0)

  defp valid_tokens?(_, n) when n < 0, do: false
  defp valid_tokens?(["(" | rest], n), do: valid_tokens?(rest, n + 1)
  defp valid_tokens?([")" | rest], n), do: valid_tokens?(rest, n - 1)
  defp valid_tokens?([_ | rest], n), do: valid_tokens?(rest, n)
  defp valid_tokens?([], n), do: n == 0

  defp parse_iter(["(" | r], s), do: parse_iter(r, [[] | s])
  defp parse_iter([")" | r], [t1, t2 | s]), do: parse_iter(r, [[t1 | t2] | s])
  defp parse_iter([o | r], [t | s]), do: parse_iter(r, [[value(o) | t] | s])
  defp parse_iter([], [t]), do: reverse_sublist(t)

  defp reverse_sublist(list) do
    list
    |> Enum.reverse()
    |> Enum.map(fn
      sublist when is_list(sublist) -> reverse_sublist(sublist)
      item -> item
    end)
  end

  defp value(string) do
    case Integer.parse(string) do
      {number, ""} -> number
      _ -> string
    end
  end
end
