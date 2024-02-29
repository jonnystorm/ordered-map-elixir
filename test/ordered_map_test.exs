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
  `Enum.take/2` on empty ordered map returns empty list
  """ do
    omap = OrderedMap.new

    assert Enum.take(omap, 1) == []
  end

  test """
  `Map.delete/2` on empty ordered map returns sane omap
  """ do
    omap = OrderedMap.new

    assert Map.delete(omap, :a_key) == omap
  end

  test """
  `put/3` is idempotent
  """ do
    omap =
      OrderedMap.new
      |> Map.put(:k, 1)

    assert Map.put(omap, :k, 1) == omap
  end

  test """
  `Enum.slice/3` works for size in excess of omap
  """ do
    omap =
      [k1: 1, k2: 2, k3: 3]
      |> Enum.into(OrderedMap.new)

    assert Enum.slice(omap, 1, 3) == [k2: 2, k3: 3]
  end

  test """
  GitHub issue #7: Problem in OrderedMap.delete

  > Where if the value is false it won't work.
  """ do
    # test our assumptions
    omap = OrderedMap.new
    assert length(omap.keys) == 0

    omap = OrderedMap.put(omap, :k, false)
    assert length(omap.keys) == 1

    # should not erroneously return the default "fail"
    assert OrderedMap.get(omap, :k, "fail") == false

    # should not overwrite the previous value `false`
    omap = OrderedMap.put_new(omap, :k, true)
    assert OrderedMap.get(omap, :k) == false

    # should raise on attempted overwrite
    assert_raise RuntimeError, fn ->
      OrderedMap.put_new!(omap, :k, true)
    end

    # should not fail to remove existing key/value
    omap = OrderedMap.delete(omap, :k)
    assert length(omap.keys) == 0
  end
end
