defmodule Aoc21.Elves do
  @moduledoc """
  Elves is an helper module containing common tasks such as reading the input file relative to the challange file and some simple comversion tools
  """

  defmacro __using__(_opts) do
    quote do
      defp input() do
        input_path =
          __ENV__.file
          |> Path.dirname()
          |> Path.join("input.txt")

        with {:ok, contents} <- File.read(input_path) do
          contents
        end
      end

      defp input_as_lines() do
        input()
        |> String.trim()
        |> String.split("\n")
      end

      defp input_as_ints() do
        input_as_lines()
        |> Enum.map(&to_int/1)
        |> Enum.filter(fn i -> i != nil end)
      end

      defp to_int(item) do
        with {int_value, _rest} <- Integer.parse(item) do
          int_value
        else
          _ -> nil
        end
      end
    end
  end
end
