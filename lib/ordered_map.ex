# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule OrderedMap do
  defstruct keys: [], map: %{}, size: 0

  @type t :: %OrderedMap{
    keys: list,
    map: map,
    size: non_neg_integer
  }

  @doc """
  Returns a new ordered map.

  ## Examples

      iex> OrderedMap.new
      %OrderedMap{keys: [], map: %{}, size: 0}
  """
  def new, do: %OrderedMap{}

  @doc """
  Deletes the entry in `ordered_map` having key `key`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.delete(ordered_map, "key1")
      %OrderedMap{keys: ["key2"], map: %{"key2" => 2}, size: 1}

      iex> ordered_map = %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
      iex> OrderedMap.delete(ordered_map, "key2")
      %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}

      iex> OrderedMap.delete(%OrderedMap{}, "key")
      %OrderedMap{keys: [], map: %{}, size: 0}
  """
  def delete(ordered_map, key)
  def delete(%OrderedMap{keys: keys, map: map, size: size} = ordered_map, key)
      when size > 0
  do
    if map[key] do
      %OrderedMap{
        keys: List.delete(keys, key),
         map: Map.delete(map, key),
        size: size - 1
      }

    else
      ordered_map
    end
  end
  def delete(%OrderedMap{} = ordered_map, _), do: ordered_map

  @doc """
  Gets the value for a specific `key`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.get(ordered_map, "key2")
      2

      iex> ordered_map = %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
      iex> OrderedMap.get(ordered_map, "key2")
      nil

      iex> OrderedMap.get(%OrderedMap{}, "key")
      nil

      iex> OrderedMap.get(%OrderedMap{}, "key", :some_default)
      :some_default
  """
  def get(ordered_map, key, default \\ nil)
  def get(%OrderedMap{map: map}, key, default), do: map[key] || default

  @doc """
  Returns whether a given `key` exists in the given `ordered_map`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.has_key?(ordered_map, "key1")
      true

      iex> OrderedMap.has_key?(%OrderedMap{}, "key")
      false
  """
  def has_key?(ordered_map, key)
  def has_key?(%OrderedMap{map: map}, key) do
    Map.has_key?(map, key)
  end

  @doc """
  Returns all keys from `ordered_map`.

  ## Examples
      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.keys(ordered_map)
      ["key1", "key2"]

      iex> OrderedMap.keys(%OrderedMap{})
      []
  """
  def keys(ordered_map)
  def keys(%OrderedMap{keys: keys}), do: Enum.reverse(keys)

  @doc """
  Puts the given `value` under `key`.

  ## Examples

      iex> ordered_map = %OrderedMap{}
      iex> ordered_map = OrderedMap.put(ordered_map, "key1", 1)
      %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
      iex> OrderedMap.put(ordered_map, "key2", 2)
      %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
  """
  def put(ordered_map, key, value)
  def put(%OrderedMap{keys: keys, map: map, size: size}, key, value) do
    new_keys = (map[key] && keys) || [key | keys]
    new_size = (map[key] && size) || size + 1

    %OrderedMap{
      keys: new_keys,
       map: Map.put(map, key, value),
      size: new_size,
    }
  end

  @doc """
  Returns all values from `ordered_map`.

  ## Examples

    iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
    iex> OrderedMap.values(ordered_map)
    [1, 2]

    iex> OrderedMap.values(%OrderedMap{})
    []
  """
  def values(ordered_map)
  def values(%OrderedMap{} = ordered_map) do
    Enum.map(ordered_map, & elem(&1, 1))
  end
end

defimpl Enumerable, for: OrderedMap do
  @type t :: OrderedMap.t

  @type acc :: {:cont, term} | {:halt, term} | {:suspend, term}
  @type continuation :: (acc -> result)
  @type reducer :: (term, term -> acc)
  @type result :: {:done, term}
                | {:halted, term}
                | {:suspended, term, continuation}

  defp _reduce(_, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  defp _reduce(omap, {:suspend, acc}, fun)  do
    {:suspended, acc, &_reduce(omap, &1, fun)}
  end
  defp _reduce(%{keys: []}, {:cont, acc}, _fun) do
    {:done, Enum.reverse(acc)}
  end
  defp _reduce(%{keys: [h | t], map: map}, {:cont, acc}, fun)  do
    _reduce(%{keys: t, map: map}, fun.({h, map[h]}, acc), fun)
  end

  @spec reduce(t, acc, reducer) :: result
  def reduce(ordered_map, acc, fun) do
    _reduce(ordered_map, acc, fun)
  end

  @spec member?(t, term) :: {:ok, boolean} | {:error, module}
  def member?(ordered_map, key) do
    OrderedMap.has_key?(ordered_map, key)
  end

  @spec count(t) :: {:ok, non_neg_integer} | {:error, module}
  def count(ordered_map) do
    {:ok, ordered_map.size}
  end
end
