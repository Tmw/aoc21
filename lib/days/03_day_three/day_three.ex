defmodule Aoc21.DayThree do
  use Aoc21.Elves

  defp parse_line(line, acc \\ [])
  defp parse_line(<<>>, acc), do: acc

  defp parse_line(<<h::binary-size(1), rest::binary>>, acc),
    do: parse_line(rest, acc ++ [to_int(h)])

  # expected to return 2648450
  # parsing each line and feeding it to the average function described below.
  # turning these digits into an integer using undigits gives us the gamma
  # turning these integer values into an bitstring and grabbing the numerical value
  # from that gives us the gamma. XOR-ing with a mask of ones gives us the epsilon.
  # multiplying those together gives us the answer of part A
  def part_one do
    averages =
      input_as_lines()
      |> Enum.map(&parse_line/1)
      |> get_averages()

    bit_length = length(averages)
    gamma = Integer.undigits(averages, 2)
    epsilon = Bitwise.bxor(gamma, create_mask(bit_length))

    gamma * epsilon
  end

  #  ¯\_(ツ)_/¯
  #  And part A once more but without using nx 
  def without_nx do
    split = fn row ->
      {{min, _}, {max, _}} =
        row
        |> Enum.frequencies()
        |> Enum.min_max_by(fn {x, value} -> {value, x} end)

      [min, max]
    end

    to_number = fn item ->
      item
      |> Tuple.to_list()
      |> List.to_string()
      |> String.to_integer(2)
    end

    [epsilon, gamma] =
      input_as_lines()
      |> Enum.map(&String.graphemes/1)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(split)
      |> Enum.zip()
      |> Enum.map(to_number)

    epsilon * gamma
  end

  # expected to return 2845944
  # Passing the parsed lines to our search function for finding both the oxygen and the co2 readings.
  def part_two do
    # test_input_as_lines()
    readings =
      input_as_lines()
      |> Enum.map(&parse_line/1)

    oxygen =
      readings
      |> search(predicate: &Kernel.==/2)
      |> Integer.undigits(2)

    co2 =
      readings
      |> search(predicate: &Kernel.!=/2)
      |> Integer.undigits(2)

    oxygen * co2
  end

  # Search will find the readings using a given predicate.
  # Each iteration we're eliminating candidates and re-calculate
  # the new average on the remainder of the candidates.
  # We repeat this proces until we have one candidate that matches the predicate
  # on the bits from left to right.
  defp search(list, predicate: predicate) do
    # grab size of list inside nested list
    highest_bit = list |> hd() |> length()

    Enum.reduce_while(0..(highest_bit - 1), list, fn idx, list ->
      averages = get_averages(list)
      expected = Enum.at(averages, idx)

      # apply predicate on the candidate list
      remainder =
        Enum.filter(list, fn candidate ->
          predicate.(Enum.at(candidate, idx), expected)
        end)

      # if we filtered down to a single value,
      # unwrap and halt the search. Else continue
      # on the remainder of the list
      if length(remainder) > 1 do
        {:cont, remainder}
      else
        {:halt, remainder |> hd}
      end
    end)
  end

  # We're using Nx tensors to get the mean over the Y axis
  # By rounding the mean we're transforming to 1.0 / 0.0 values.
  # Feeding the flattened list to trunc/1 gives us a list of integer values
  defp get_averages(input_lines) do
    input_lines
    |> Nx.tensor()
    |> Nx.mean(axes: [0])
    |> Nx.round()
    |> Nx.to_flat_list()
    |> Enum.map(&trunc/1)
  end

  defp create_mask(length) do
    mask_as_list = for _ <- 1..length, into: [], do: 1
    Integer.undigits(mask_as_list, 2)
  end
end
