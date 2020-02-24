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
    end
  end
end
