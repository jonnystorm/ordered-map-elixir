defmodule OrderedMapTest do
  use ExUnit.Case
  doctest OrderedMap

  test "Access behaviour returns a value" do
    ordered_map =
      OrderedMap.new
      |> OrderedMap.put(:key, 1)

    assert ordered_map[:key] == 1
  end

  test "Access behaviour returns nil" do
    ordered_map = OrderedMap.new

    assert ordered_map[:key] == nil
  end

  test "Collectable protocol returns empty ordered map" do
    ordered_map =
      [ {"key1", 1},
        {"key2", 2},
      ] |> Enum.into(OrderedMap.new)

    assert ordered_map ==
      %OrderedMap{
        keys: ["key2", "key1"],
        map: %{"key1" => 1, "key2" => 2},
        size: 2,
      }
  end

  test """
  `Enum.take/2` on empty ordered map returns empty list.
  """ do
    omap = OrderedMap.new

    assert Enum.take(omap, 1) == []
  end

  test """
  `Map.delete/2` on empty ordered map returns sane omap.
  """ do
    omap = OrderedMap.new

    assert Map.delete(omap, :a_key) == omap
  end
end
