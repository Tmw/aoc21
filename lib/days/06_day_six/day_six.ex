defmodule Aoc21.DaySix do
  use Aoc21.Elves

  def part_one do
    solve(80, parse()) |> Enum.count()
  end

  # let's make it recursive! recurse until the n-th day is reached.
  defp solve(0, fishes), do: fishes

  defp solve(days_to_go, fishes) do
    fishes = Enum.map(fishes, &Kernel.-(&1, 1))

    # all fishes whose internal counter reached < 0;
    # we'll generate new fish for those. These new fish
    # will get appended to the end
    new_fishes =
      fishes
      |> Enum.count(&Kernel.<(&1, 0))
      |> new_fishes()

    # fishes whose internal counter reached < 0 will be reset to 6.
    fishes =
      Enum.map(fishes, fn
        c when c < 0 -> 6
        c -> c
      end)

    solve(days_to_go - 1, fishes ++ new_fishes)
  end

  # generate n new fishes. new fishes start with an internal clock of 8
  defp new_fishes(0), do: []

  defp new_fishes(amount) do
    for _ <- 1..amount, do: 8
  end

  # this challange has a single line of input,
  # parse it as a list of integers
  defp parse do
    input() |> String.split(",") |> Enum.map(&to_int/1)
  end
end
