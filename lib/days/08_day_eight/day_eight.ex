defmodule Aoc21.DayEight do
  use Aoc21.Elves
  @pattern ~r/ |\|/

  # let's be very naive here and pretend for part two we wont need to
  # decipher _all_ given digits and instead only count the ones with
  # an unique pattern for now.
  def part_one do
    frequencies =
      parse()
      |> Enum.flat_map(&elem(&1, 1))
      |> Enum.map(&String.length/1)
      |> Enum.frequencies()

    # pluck the signals with lengths 2 (for a one), 3 (for a seven), 
    # 4 (for a four) and 7 (for an eight) sum these counts and voila, 
    # that's the answer for part one.
    frequencies
    |> Map.take([2, 3, 4, 7])
    |> Map.values()
    |> Enum.sum()
  end

  # parse each line. The first ten signals are all possible combinations
  # the last four signals are the actual segments being displayed.
  defp parse do
    input_as_lines()
    |> Enum.map(&Regex.split(@pattern, &1, trim: true))
    |> Enum.map(&sort_signals/1)
    |> Enum.map(&Enum.split(&1, 10))
  end

  # to make processing easier, we'll sort each signal alphabetically
  defp sort_signals(signals) do
    Enum.map(signals, &sort_signal/1)
  end

  defp sort_signal(signal) do
    signal
    |> String.split("", trim: true)
    |> Enum.sort()
    |> Enum.join()
  end
end
