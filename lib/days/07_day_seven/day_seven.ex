defmodule Aoc21.DaySeven do
  use Aoc21.Elves

  def part_one do
    parsed() |> solve(&calculate_cost_linear/2)
  end

  def part_two do
    parsed() |> solve(&calculate_cost_triangular/2)
  end

  defp solve(crabs, cost_function) do
    unique_positions =
      crabs
      |> Enum.sort()
      |> Enum.uniq()

    costs =
      unique_positions
      |> Enum.map(&cost_function.(crabs, &1))

    {_cheapest_position, fuel_cost} =
      unique_positions
      |> Enum.zip(costs)
      |> Enum.sort_by(&elem(&1, 1))
      |> List.first()

    fuel_cost |> trunc()
  end

  # calculate cost linearily. Each step is 1 unit of fuel
  defp calculate_cost_linear(crabs, desired_position) do
    Enum.reduce(crabs, 0, fn crab, acc ->
      acc + abs(crab - desired_position)
    end)
  end

  # calculate the cost using triangular numbers
  # see: https://en.wikipedia.org/wiki/Triangular_number
  defp calculate_cost_triangular(crabs, desired_position) do
    Enum.reduce(crabs, 0, fn crab, acc ->
      steps = abs(crab - desired_position)
      acc + (steps ** 2 + steps) / 2
    end)
  end

  defp parsed do
    input()
    |> String.split(",")
    |> Enum.map(&to_int/1)
  end
end
