defmodule Aoc21.DayEight do
  use Aoc21.Elves

  @decoder Aoc21.DayEight.Decoder
  @pattern ~r/ |\|/

  # decipher all digits, take the frequencies, pluck the easy ones (1, 4, 7, 8)
  # and return their sum.
  def part_one do
    parse()
    |> Enum.flat_map(fn {all_signals, value_signals} ->
      translation = @decoder.decode(all_signals)
      Enum.map(value_signals, &Map.get(translation, &1))
    end)
    |> Enum.frequencies()
    |> Map.take([1, 4, 7, 8])
    |> Map.values()
    |> Enum.sum()
  end

  # decipher all digits per line and turn back into a number.
  # return the sum of all numbers across all lines of the input
  def part_two do
    parse()
    |> Enum.map(fn {all_signals, value_signals} ->
      translation = @decoder.decode(all_signals)

      value_signals
      |> Enum.map(&Map.get(translation, &1))
      |> Integer.undigits()
    end)
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
    sorter = fn signal ->
      signal
      |> String.to_charlist()
      |> Enum.sort()
    end

    Enum.map(signals, sorter)
  end
end

defmodule Aoc21.DayEight.Decoder do
  def decode(signals, decoded \\ %{})
  def decode([], decoded), do: decoded

  # recusrive function that takes the first signal off the list and tries to
  # decode it. Succesful decodes are stored in the `decoded` map, however
  # if we are unable to decode the signal at this time (eg. because the easy
  # cases have not been decoded yet) we're moving the signal to the end of the
  # list and recurse.
  #
  # We're assuming that the second time around the easy cases (1, 7, 4 and 8)
  # are decoded and we'll finish the decode.
  def decode([signal | rest], decoded) do
    case decode_signal(signal, decoded) do
      {signal, value} ->
        decode(rest, Map.put(decoded, signal, value))

      nil ->
        decode(rest ++ [signal], decoded)
    end
  end

  defp decode_signal(signal, decoded) when is_binary(signal),
    do: signal |> String.to_charlist() |> decode_signal(decoded)

  # Definition for simple cases with unique signal lengths (2,3,4 and 7)
  defp decode_signal(signal, _decoded) when length(signal) == 2, do: {signal, 1}
  defp decode_signal(signal, _decoded) when length(signal) == 3, do: {signal, 7}
  defp decode_signal(signal, _decoded) when length(signal) == 4, do: {signal, 4}
  defp decode_signal(signal, _decoded) when length(signal) == 7, do: {signal, 8}

  # More complex cases where length is 5 such as 5, 2 and 3
  #
  # - When the signal has two overlapping segments with the digit `one` and 
  #   three overlapping segments with the digit `four` we can can be fairly 
  #   certain we're seeing the signal for the digit three.
  #
  # - If the signal has one overlapping segment with the digit `one` and two
  #   overlapping segments with the digit `four` we can assume we've got a two.
  #
  # - when the signal has one overlapping segment with the digit `one` and three
  #   overlapping segments with the digit `four` we know we're seeing a five.
  #
  defp decode_signal(signal, decoded) when length(signal) == 5 do
    with {one_pattern, _} <- find_signal_for(decoded, 1),
         {four_pattern, _} <- find_signal_for(decoded, 4) do
      case {overlap(signal, one_pattern), overlap(signal, four_pattern)} do
        {2, 3} -> {signal, 3}
        {1, 2} -> {signal, 2}
        {1, 3} -> {signal, 5}
      end
    end
  end

  # Other (more complex) cases where length is 6 such as 9, 6 or 0
  #
  # - When the signal has two overlapping segments with the digit `one` and
  #   three overlapping segments with the digit `four`, we assume it's a 0.
  #
  # - When the signal has two overlapping segments with the digit `one` and
  #   four overlapping segments with the digit `four`, we assume it's a 9.
  #
  # - When the signal has one overlapping segment with the digit `one` and
  #   three overlapping segments with the digit `four`, we assume it's a 6.
  #
  defp decode_signal(signal, decoded) when length(signal) == 6 do
    # find the four and find the one in the decoded map...
    with {one_pattern, _} <- find_signal_for(decoded, 1),
         {four_pattern, _} <- find_signal_for(decoded, 4) do
      case {overlap(signal, one_pattern), overlap(signal, four_pattern)} do
        {2, 3} -> {signal, 0}
        {2, 4} -> {signal, 9}
        {1, 3} -> {signal, 6}
      end
    end
  end

  defp decode_signal(_signal, _decoded), do: nil

  # reverse lookup in the dictionary to find the pattern
  # that belongs to the given value.
  defp find_signal_for(dictionary, value) do
    Enum.find(dictionary, &(elem(&1, 1) == value))
  end

  # calculate overlap in two signals. Returns the amount
  # of segments that are activated in both signals at once.
  defp overlap(signal_a, signal_b) do
    signal_a
    |> Enum.concat(signal_b)
    |> Enum.frequencies()
    |> Enum.filter(fn {_k, v} -> v > 1 end)
    |> Enum.count()
  end
end
