# Copyright © 2017 Jonathan Storm <jds@idio.link>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule OrderedMap do
  defstruct keys: nil, map: nil, size: nil

  @behaviour Access

  @type key :: any

  @type t :: %OrderedMap{
    keys: list,
     map: map,
    size: non_neg_integer,
  }

  @doc """
  Returns a new ordered map.

  ## Examples

      iex> OrderedMap.new()
      %OrderedMap{keys: [], map: %{}, size: 0}
  """
  @spec new :: t

  def new, do: %OrderedMap{keys: [], map: %{}, size: 0}

  @doc """
  Deletes the entry in `ordered_map` having key `key`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.delete(ordered_map, "key1")
      %OrderedMap{keys: ["key2"], map: %{"key2" => 2}, size: 1}

      iex> ordered_map = %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
      iex> OrderedMap.delete(ordered_map, "key2")
      %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}

      iex> OrderedMap.delete(OrderedMap.new(), "key")
      %OrderedMap{keys: [], map: %{}, size: 0}
  """
  @spec delete(t, key) :: t

  def delete(ordered_map, key)
  def delete(%{keys: keys, map: map, size: size} = ordered_map, key)
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

  def delete(%OrderedMap{} = ordered_map, _),
    do: ordered_map

  @doc """
  Fetches the value for a specific `key` in the given `ordered_map`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.fetch(ordered_map, "key1")
      {:ok, 1}

      iex> ordered_map = OrderedMap.new()
      iex> OrderedMap.fetch(ordered_map, "key")
      :error
  """
  @spec fetch(t, key) :: {:ok, term} | :error

  def fetch(ordered_map, key) do
    if value = get(ordered_map, key) do
      {:ok, value}
    else
      :error
    end
  end

  @doc """
  Gets the value for a specific `key`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.get(ordered_map, "key2")
      2

      iex> ordered_map = %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
      iex> OrderedMap.get(ordered_map, "key2")
      nil

      iex> OrderedMap.get(OrderedMap.new(), "key")
      nil

      iex> OrderedMap.get(OrderedMap.new(), "key", :some_default)
      :some_default
  """
  @spec get(t, key, default :: term) :: term

  def get(ordered_map, key, default \\ nil)
  def get(%{map: map}, key, default),
    do: map[key] || default

  @doc """
  Gets the value from `key` and updates it, all in one pass.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.get_and_update(ordered_map, "key1", fn current -> {current, 3} end)
      {1, %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 3, "key2" => 2}, size: 2}}
  """
  @spec get_and_update(t, key, list) :: {term, t}

  def get_and_update(ordered_map, key, fun) when is_function(fun) do
    case fun.(get(ordered_map, key)) do
      {return_value, new_value} ->
        new = put(ordered_map, key, new_value)

        {return_value, new}

      :pop ->
        pop(ordered_map, key)
    end
  end

  @doc """
  Returns whether a given `key` exists in the given `ordered_map`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.has_key?(ordered_map, "key1")
      true

      iex> OrderedMap.has_key?(OrderedMap.new(), "key")
      false
  """
  @spec has_key?(t, term) :: t

  def has_key?(ordered_map, key)
  def has_key?(%{map: map}, key),
    do: Map.has_key?(map, key)

  @doc """
  Returns all keys from `ordered_map`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.keys(ordered_map)
      ["key1", "key2"]

      iex> OrderedMap.keys(OrderedMap.new())
      []
  """
  @spec keys(t) :: [term]

  def keys(ordered_map)
  def keys(%{keys: keys}),
    do: Enum.reverse(keys)

  @doc """
  Returns and removes the value associated with `key` in `ordered_map`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.pop(ordered_map, "key1")
      {1, %OrderedMap{keys: ["key2"], map: %{"key2" => 2}, size: 1}}
  """
  @spec pop(t, key) :: {term, t}

  def pop(ordered_map, key)
  def pop(%{keys: keys, map: map, size: size}, key) do
    {value, vestige} = Map.pop(map, key)

    new = %OrderedMap{
       keys: List.delete(keys, key),
        map: vestige,
       size: size - 1,
    }

    {value, new}
  end

  @doc """
  Puts the given `value` under `key`.

  ## Examples

      iex> ordered_map = OrderedMap.new()
      iex> ordered_map = OrderedMap.put(ordered_map, "key1", 1)
      %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
      iex> OrderedMap.put(ordered_map, "key2", 2)
      %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.put(ordered_map, "key2", 3)
      %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 3}, size: 2}
  """
  @spec put(t, term, term) :: t

  def put(ordered_map, key, value)
  def put(%{keys: keys, map: map, size: size}, key, value) do
    new_keys = map[key] && keys || [key|keys]
    new_size = map[key] && size || size + 1

    %OrderedMap{
      keys: new_keys,
       map: Map.put(map, key, value),
      size: new_size,
    }
  end

  @doc """
  Puts the given `value` under `key` unless the entry `key` already exists.

  ## Examples

      iex> ordered_map = OrderedMap.new()
      iex> ordered_map = OrderedMap.put_new(ordered_map, "key1", 1)
      %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
      iex> OrderedMap.put_new(ordered_map, "key1", 2)
      %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
  """
  @spec put_new(t, term, term) :: t

  def put_new(ordered_map, key, value)
  def put_new(%{map: map} = ordered_map, key, value) do
    if map[key] do
      ordered_map
    else
      put(ordered_map, key, value)
    end
  end

  @doc """
  Puts the given `value` under `key`. If `key` exists, a `RuntimeError` is raised.

  ## Examples

      iex> ordered_map = OrderedMap.new()
      iex> ordered_map = OrderedMap.put_new!(ordered_map, "key1", 1)
      %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
      iex> OrderedMap.put_new!(ordered_map, "key1", 2)
      ** (RuntimeError) key "key1" already exists in: %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
  """
  @spec put_new!(t, term, term) :: t | no_return

  def put_new!(ordered_map, key, value)
  def put_new!(%{map: map} = ordered_map, key, value) do
    if map[key] do
      raise "key #{inspect key} already exists in: #{inspect ordered_map}"
    else
      put(ordered_map, key, value)
    end
  end

  @doc """
  Returns all values from `ordered_map`.

  ## Examples

      iex> ordered_map = %OrderedMap{keys: ["key2", "key1"], map: %{"key1" => 1, "key2" => 2}, size: 2}
      iex> OrderedMap.values(ordered_map)
      [1, 2]

      iex> OrderedMap.values(OrderedMap.new())
      []
  """
  @spec values(t) :: [term]

  def values(ordered_map) do
    Enum.map(ordered_map, & elem(&1, 1))
  end
end

defimpl Collectable, for: OrderedMap do
  def into(ordered_map) do
      collector_fun = fn
         map, {:cont, {key, value}} -> OrderedMap.put(map, key, value)
         map,  :done        -> map
        _set,  :halt        -> :ok
      end

      {ordered_map, collector_fun}
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

  defp _reduce(_, {:halt, acc}, _fun),
    do: {:halted, acc}

  defp _reduce(ordered_map, {:suspend, acc}, fun),
    do: {:suspended, acc, &_reduce(ordered_map, &1, fun)}

  defp _reduce(%{keys: []}, {:cont, acc}, _fun),
    do: {:done, Enum.reverse(acc)}

  defp _reduce(%{keys: [h | t], map: map}, {:cont, acc}, fun),
    do: _reduce(%{keys: t, map: map}, fun.({h, map[h]}, acc), fun)

  @spec reduce(t, acc, reducer) :: result

  def reduce(ordered_map, acc, fun),
    do: _reduce(ordered_map, acc, fun)

  @spec member?(t, term) :: {:ok, boolean} | {:error, module}

  def member?(ordered_map, key),
    do: OrderedMap.has_key?(ordered_map, key)

  @spec count(t) :: {:ok, non_neg_integer} | {:error, module}

  def count(ordered_map),
    do: {:ok, ordered_map.size}
end
