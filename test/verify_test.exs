defmodule Washup.Test.Verify do
  use ExUnit.Case

  test "map" do
    assert_raise Washup.RequiredError, fn ->
      Washup.verify(%{key1: :required, key2: "key2"})
    end
  end

  test "list" do
    assert_raise Washup.RequiredError, fn ->
      Washup.verify([1, :required, 3])
    end
  end

  test "map -> list" do
    assert_raise Washup.RequiredError, fn ->
      Washup.verify(%{key: [1, 2, :required]})
    end
  end

  test "list -> map" do
    assert_raise Washup.RequiredError, fn ->
      Washup.verify([%{key1: :required, key2: 101}, :required, 202])
    end
  end

  test "list -> list" do
    assert_raise Washup.RequiredError, fn ->
      Washup.verify([[1, :required, 3], :required, 3])
    end
  end

  test "map -> map" do
    assert_raise Washup.RequiredError, fn ->
      Washup.verify(%{key1: %{a: 1, b: :required, c: 3}, key2: :required, key3: %{q: "q"}})
    end
  end
end
