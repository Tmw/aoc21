defmodule Aoc21.DaySix do
  use Aoc21.Elves

  def part_one do
    get_initial()
    |> solve(80)
    |> Map.values()
    |> Enum.sum()
  end

  def part_two do
    get_initial()
    |> solve(256)
    |> Map.values()
    |> Enum.sum()
  end

  defp solve(state, 0), do: state

  defp solve(state, days_to_go) do
    # move all fishes one bucket down as their internal clock ticks away
    state =
      state
      |> Map.to_list()
      |> Enum.map(fn {bucket, fishes} -> {bucket - 1, fishes} end)

    # convert the updated list back to a map where we optionally pluck
    # the fishes that have reached the -1 status (time to repopulate)
    {offspring, state} = state |> Map.new() |> Map.pop(-1)

    state =
      state
      # add offspring to the 8 bucket
      |> Map.put(8, offspring)
      |> Map.update(6, 0, fn sixers -> sixers + offspring end)

    solve(state, days_to_go - 1)
  end

  # this challange has a single line of input,
  # parse it as a list of integers
  defp parse do
    input() |> String.split(",") |> Enum.map(&to_int/1)
  end

  defp get_initial do
    initial = %{
      0 => 0,
      1 => 0,
      2 => 0,
      3 => 0,
      4 => 0,
      5 => 0,
      6 => 0,
      7 => 0,
      8 => 0
    }

    parse()
    |> Enum.frequencies()
    |> then(&Map.merge(initial, &1))
  end
end
