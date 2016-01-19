defmodule Washup do
  @doc """
  Walk a possibly nested data structure, filtering out nil values.

  ## Example
      iex> jenny = %{name: "Jennifer", age: 27, rank: "Captain", pets: nil}
      iex> Washup.filter(jenny)
      %{name: "Jennifer", age: 27, rank: "Captain"}
  """
  def filter(it) do
    cond do
      is_map(it) and Map.has_key?(it, :__struct__) -> filter(Map.from_struct(it))
      is_map(it) -> for {k,v} <- it, not is_nil(v), into: %{}, do: {k, do_filter(v)}
      is_list(it) -> for x <- it, not is_nil(x), do: do_filter(x)
      true -> it
    end
  end

  defp do_filter(v) do
    cond do
      is_map(v) -> filter(v)
      is_list(v) -> filter(v)
      true -> v
    end
  end

  defmodule RequiredError do
    defexception path: nil, message: nil
  end

  @doc """
  Walk a possibly nested data structure and raise an exception if a :required
  is found.

  ## Example
      iex> jenny = %{name: "Jennifer", age: 27, rank: "Captain", pets: [%{species: :required}]}
      iex> Washup.verify(jenny)
      ** (Washup.RequiredError) pets->listidx->species required
  """
  def verify(it, path\\[]) do
    cond do
      is_map(it) and Map.has_key?(it, :__struct__) -> verify(Map.from_struct(it), path)
      is_map(it) -> for {k,v} <- it, into: %{}, do: {k, verify(v, [k|path])}
      is_list(it) -> for x <- it, do: verify(x, ["listidx"|path])
      true -> verify_val(it, path)
    end
  end

  defp verify_val(val, path) do
    case val do
      :required -> raise RequiredError,
        path: path,
        message: Enum.join(Enum.reverse(path), "->") <> " required"
      _ -> val
    end
  end
end
