defmodule OrderedMap.Utility do
  @moduledoc false

  defmacro slice_list_fun(list, size) do
    fun =
      fn args ->
        {:&, [],
          [
            { {:., [],
                [ {:__aliases__,
                    [alias: false],
                    [:Enumerable, :List]
                  },
                  :slice,
                ]
              },
              [],
              args
            }
          ]
        }
      end

    cond do
      Kernel.function_exported?(
        Enumerable.List,
        :slice,
        3
      ) ->
        #&Enumerable.List.slice(unquote(list), &1, &2)
        fun.([list, {:&, [], [1]}, {:&, [], [2]}])

      Kernel.function_exported?(
        Enumerable.List,
        :slice,
        4
      ) ->
        #&Enumerable.List.slice(unquote(list), &1, &2, unquote(size))
        fun.([list, {:&, [], [1]}, {:&, [], [2]}, size])

      Kernel.function_exported?(
        Enumerable.List,
        :slice,
        1
      ) ->
        # Rather than returning an Enumerable.slicing_fun(),
        # we opt to pass an Enumerable.to_list_fun().
        quote do
          fn _term -> unquote(list) end
        end
    end
  end
end
