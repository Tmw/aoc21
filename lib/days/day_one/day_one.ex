defmodule Aoc21.DayOne do
  use Aoc21.Elves

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
end
