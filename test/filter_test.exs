defmodule Washup.Test.Filter do
  use ExUnit.Case

  test "map" do
    assert Washup.filter(%{key1: nil, key2: "key2"}) == %{key2: "key2"}
  end

  test "list" do
    assert Washup.filter([1, nil, 3]) == [1, 3]
  end

  test "map -> list" do
    assert Washup.filter(%{key: [1, 2, nil]}) == %{key: [1, 2]}
  end

  test "list -> map" do
    assert Washup.filter([%{key1: nil, key2: 101}, nil, 202]) == [%{key2: 101}, 202]
  end

  test "list -> list" do
    assert Washup.filter([[1, nil, 3], nil, 3]) == [[1, 3], 3]
  end

  test "map -> map" do
    assert Washup.filter(%{key1: %{a: 1, b: nil, c: 3}, key2: nil, key3: %{q: "q"}}) ==
      %{key1: %{a: 1, c: 3}, key3: %{q: "q"}}
  end
end
