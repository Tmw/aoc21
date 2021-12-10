defmodule Aoc21.DayOne do
  defp is_higher?({a, b}) when b > a, do: true
  defp is_higher?(_), do: false

  def part_one do
    readings = input_as_ints()

    readings
    |> Enum.zip(Enum.drop(readings, 1))
    |> Enum.filter(&is_higher?/1)
    |> Enum.count()
  end

  def part_two do
    readings = input_as_ints()

    sums =
      readings
      |> Enum.chunk_every(3, 1)
      |> Enum.map(&Enum.sum/1)

    sums
    |> Enum.zip(Enum.drop(sums, 1))
    |> Enum.filter(&is_higher?/1)
    |> Enum.count()
  end

  defp input() do
    input_path =
      __ENV__.file
      |> Path.dirname()
      |> Path.join("input.txt")

    with {:ok, contents} <- File.read(input_path) do
      contents
    end
  end

  defp input_as_ints() do
    input()
    |> String.split("\n")
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
