# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule OrderedMap do
  @behaviour Access

  defstruct [:keys, :map, :size]

  @type key :: any

  @type t
    :: %OrderedMap{
         keys: [key],
          map: map,
         size: non_neg_integer,
       }

  @doc """
  Returns a new ordered map.

  ## Examples

      iex> OrderedMap.new()
      %OrderedMap{keys: [], map: %{}, size: 0}
  """
  @spec new
    :: %OrderedMap{keys: [], map: %{}, size: 0}
  def new,
    do: %OrderedMap{keys: [], map: %{}, size: 0}

  @doc """
  Deletes the entry in `ordered_map` having key `key`.

  ## Examples

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key2", "key1"],
      ...>     map: %{"key1" => 1, "key2" => 2},
      ...>     size: 2,
      ...>   }
      iex> OrderedMap.delete(ordered_map, "key1")
      %OrderedMap{
        keys: ["key2"],
        map: %{"key2" => 2},
        size: 1
      }

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key1"],
      ...>     map: %{"key1" => 1},
      ...>     size: 1
      ...>   }
      iex> OrderedMap.delete(ordered_map, "key2")
      %OrderedMap{
        keys: ["key1"],
        map: %{"key1" => 1},
        size: 1
      }

      iex> OrderedMap.delete(OrderedMap.new(), "key")
      %OrderedMap{keys: [], map: %{}, size: 0}
  """
  @spec delete(t, key)
    :: t
  def delete(ordered_map, key)

  def delete(
    %{keys: keys, map: map, size: size} = omap,
    key
  )   when size > 0
  do
    if map[key] do
      %OrderedMap{
        keys: List.delete(keys, key),
         map: Map.delete(map, key),
        size: max(0, size - 1)
      }

    else
      omap
    end
  end

  def delete(%OrderedMap{} = omap, _),
    do: omap

  @doc """
  Fetches the value for a specific `key` in the given
  `ordered_map`.

  ## Examples

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key2", "key1"],
      ...>     map: %{"key1" => 1, "key2" => 2},
      ...>     size: 2,
      ...>   }
      iex> OrderedMap.fetch(ordered_map, "key1")
      {:ok, 1}

      iex> ordered_map = OrderedMap.new()
      iex> OrderedMap.fetch(ordered_map, "key")
      :error
  """
  @spec fetch(t, key)
    :: {:ok, term}
     | :error
  @impl Access
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

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key2", "key1"],
      ...>     map: %{"key1" => 1, "key2" => 2},
      ...>     size: 2,
      ...>   }
      iex> OrderedMap.get(ordered_map, "key2")
      2

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key1"],
      ...>     map: %{"key1" => 1},
      ...>     size: 1,
      ...>   }
      iex> OrderedMap.get(ordered_map, "key2")
      nil

      iex> OrderedMap.get(OrderedMap.new(), "key")
      nil

      iex> OrderedMap.get(OrderedMap.new(), "key", :default)
      :default
  """
  @spec get(t, key, default :: term)
    :: term
  def get(ordered_map, key, default \\ nil)

  def get(%{map: map}, key, default),
    do: map[key] || default

  @doc """
  Gets the value from `key` and updates it, all in one pass.

  ## Examples

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key2", "key1"],
      ...>     map: %{"key1" => 1, "key2" => 2},
      ...>     size: 2,
      ...>   }
      iex> fun = fn current -> {current, 3} end
      iex> OrderedMap.get_and_update(ordered_map, "key1",fun)
      { 1,
        %OrderedMap{
          keys: ["key2", "key1"],
          map: %{"key1" => 3, "key2" => 2},
          size: 2,
        }
      }
  """
  @spec get_and_update(t, key, (any -> any))
    :: {any, t}
  @impl Access
  def get_and_update(ordered_map, key, fun)
      when is_function(fun)
  do
    case fun.(get(ordered_map, key)) do
      {return_value, new_value} ->
        new =
          put(ordered_map, key, new_value)

        {return_value, new}

      :pop ->
        pop(ordered_map, key)
    end
  end

  @doc """
  Returns whether a given `key` exists in the given
  `ordered_map`.

  ## Examples

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key2", "key1"],
      ...>     map: %{"key1" => 1, "key2" => 2},
      ...>     size: 2,
      ...>   }
      iex> OrderedMap.has_key?(ordered_map, "key1")
      true

      iex> OrderedMap.has_key?(OrderedMap.new(), "key")
      false
  """
  @spec has_key?(t, any)
    :: boolean
  def has_key?(ordered_map, key)

  def has_key?(%{map: map}, key),
    do: Map.has_key?(map, key)

  @doc """
  Returns all keys from `ordered_map`.

  ## Examples

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key2", "key1"],
      ...>     map: %{"key1" => 1, "key2" => 2},
      ...>     size: 2,
      ...>   }
      iex> OrderedMap.keys ordered_map
      ["key1", "key2"]

      iex> OrderedMap.keys OrderedMap.new()
      []
  """
  @spec keys(t)
    :: [term]
  def keys(ordered_map)

  def keys(%{keys: keys}),
    do: Enum.reverse(keys)

  @doc """
  Returns and removes the value associated with `key` in
  `ordered_map`.

  ## Examples

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key2", "key1"],
      ...>     map: %{"key1" => 1, "key2" => 2},
      ...>     size: 2,
      ...>   }
      iex> OrderedMap.pop(ordered_map, "key1")
      { 1,
        %OrderedMap{
          keys: ["key2"],
          map: %{"key2" => 2},
          size: 1,
        }
      }
  """
  @spec pop(t, key)
    :: {term, t}
  @impl Access
  def pop(ordered_map, key)

  def pop(%{keys: keys, map: map, size: size}, key) do
    {value, vestige} = Map.pop(map, key)

    new = %OrderedMap{
       keys: List.delete(keys, key),
        map: vestige,
       size: max(0, size - 1),
    }

    {value, new}
  end

  @doc """
  Puts the given `value` under `key`.

  ## Examples

      iex> ordered_map = OrderedMap.new()
      iex> ordered_map =
      ...>   OrderedMap.put(ordered_map, "key1", 1)
      %OrderedMap{
        keys: ["key1"],
        map: %{"key1" => 1},
        size: 1,
      }
      iex> OrderedMap.put(ordered_map, "key2", 2)
      %OrderedMap{
        keys: ["key2", "key1"],
        map: %{"key1" => 1, "key2" => 2},
        size: 2,
      }

      iex> ordered_map =
      ...> %OrderedMap{
      ...>   keys: ["key2", "key1"],
      ...>   map: %{"key1" => 1, "key2" => 2},
      ...>   size: 2,
      ...> }
      iex> OrderedMap.put(ordered_map, "key2", 3)
      %OrderedMap{
        keys: ["key2", "key1"],
        map: %{"key1" => 1, "key2" => 3},
        size: 2,
      }
  """
  @spec put(t, term, term)
    :: t
  def put(ordered_map, key, value)

  def put(
    %{keys: keys, map: map, size: size} = omap,
    key,
    value
  ) do
    if key in keys do
      %{omap|map: Map.put(map, key, value)}
    else
      new_keys = map[key] && keys || [key|keys]
      new_size = map[key] && size || size + 1

      %OrderedMap{
        keys: new_keys,
         map: Map.put(map, key, value),
        size: new_size,
      }
    end
  end

  @doc """
  Puts the given `value` under `key` unless the entry `key`
  already exists.

  ## Examples

      iex> ordered_map = OrderedMap.new()
      iex> ordered_map =
      ...>   OrderedMap.put_new(ordered_map, "key1", 1)
      %OrderedMap{
        keys: ["key1"],
        map: %{"key1" => 1},
        size: 1,
      }
      iex> OrderedMap.put_new(ordered_map, "key1", 2)
      %OrderedMap{
        keys: ["key1"],
        map: %{"key1" => 1},
        size: 1,
      }
  """
  @spec put_new(t, term, term)
    :: t
  def put_new(ordered_map, key, value)

  def put_new(%{map: map} = ordered_map, key, value) do
    if map[key] do
      ordered_map
    else
      put(ordered_map, key, value)
    end
  end

  @doc """
  Puts the given `value` under `key`. If `key` exists, a
  `RuntimeError` is raised.

  ## Examples

      iex> ordered_map = OrderedMap.new()
      iex> ordered_map =
      ...>   OrderedMap.put_new!(ordered_map, "key1", 1)
      %OrderedMap{
        keys: ["key1"],
        map: %{"key1" => 1},
        size: 1,
      }
      iex> OrderedMap.put_new!(ordered_map, "key1", 2)
      ** (RuntimeError) key "key1" already exists in: %OrderedMap{keys: ["key1"], map: %{"key1" => 1}, size: 1}
  """
  @spec put_new!(t, term, term)
    :: t
     | no_return
  def put_new!(ordered_map, key, value)

  def put_new!(%{map: map} = omap, key, value) do
    if map[key] do
      raise "key #{inspect key} already exists in: #{inspect omap}"
    else
      put(omap, key, value)
    end
  end

  @doc """
  Returns all values from `ordered_map`.

  ## Examples

      iex> ordered_map =
      ...>   %OrderedMap{
      ...>     keys: ["key2", "key1"],
      ...>     map: %{"key1" => 1, "key2" => 2},
      ...>     size: 2,
      ...>   }
      iex> OrderedMap.values ordered_map
      [1, 2]

      iex> OrderedMap.values OrderedMap.new()
      []
  """
  @spec values(t)
    :: [term]
  def values(ordered_map),
    do: Enum.map(ordered_map, & elem(&1, 1))
end

defimpl Collectable, for: OrderedMap do
  def into(ordered_map) do
      collector_fun = fn
         (map, {:cont, {key, value}}) ->
           OrderedMap.put(map, key, value)

         (map, :done) ->
           map

        (_set, :halt) ->
          :ok
      end

      {ordered_map, collector_fun}
  end
end

defimpl Enumerable, for: OrderedMap do
  @type t :: OrderedMap.t

  @type acc
    :: {:cont, term}
     | {:halt, term}
     | {:suspend, term}

  @type continuation :: (acc -> result)
  @type reducer      :: (term, term -> acc)
  @type result
    :: {:done, term}
     | {:halted, term}
     | {:suspended, term, continuation}

  defp _reduce(_, {:halt, acc}, _fun),
    do: {:halted, acc}

  defp _reduce(omap, {:suspend, acc}, fun),
    do: {:suspended, acc, &_reduce(omap, &1, fun)}

  defp _reduce(%{keys: []}, {:cont, acc}, _fun),
    do: {:done, acc}

  defp _reduce(
    %{keys: [h|t], map: map},
    {:cont, acc},
    fun
  ) do
    next_acc = fun.({h, map[h]}, acc)

    _reduce(%{keys: t, map: map}, next_acc, fun)
  end

  @spec reduce(t, acc, reducer)
    :: result
  def reduce(ordered_map, acc, fun) do
    next_omap =
      %{ordered_map |
        keys: Enum.reverse(ordered_map.keys),
      }

    _reduce(next_omap, acc, fun)
  end

  @spec member?(t, any)
    :: {:ok, boolean}
     | {:error, atom}
  def member?(ordered_map, key)

  def member?(
    %{keys: _, map: _, size: _} = omap,
    key
  ),
    do: {:ok, OrderedMap.has_key?(omap, key)}

  def member?(_, _),
    do: {:error, __MODULE__}

  @spec count(t)
    :: {:ok, non_neg_integer}
     | {:error, module}
  def count(ordered_map)

  def count(%{keys: _, map: _, size: _} = omap),
    do: {:ok, omap.size}

  def count(_),
    do: {:error, __MODULE__}

  @type size :: non_neg_integer

  @type slicing_fun
    :: (non_neg_integer, pos_integer -> [any])

  @spec slice(t)
    :: {:ok, size, slicing_fun}
     | {:error, atom}
  def slice(ordered_map)

  def slice(%{keys: _, map: _, size: _} = omap) do
    list = Enum.into(omap, [])
    fun  = &Enumerable.List.slice(list, &1, &2, omap.size)

    {:ok, omap.size, fun}
  end

  def slice(_),
    do: {:error, __MODULE__}
end
