defmodule Aoc21.DayThree do
  use Aoc21.Elves

  defp parse_line(line, acc \\ [])
  defp parse_line(<<>>, acc), do: acc

  defp parse_line(<<h::binary-size(1), rest::binary>>, acc),
    do: parse_line(rest, acc ++ [to_int(h)])

  # expected to return 2648450
  # We're using Nx tensors to get the mean over the Y axis
  # By rounding the mean we're transforming to 1.0 / 0.0 values.
  # Feeding the flattened list to trunc/1 gives us a list of integer values
  # turning these integer values into an bitstring and grabbing the numerical value
  # from that gives us the gamma. XOR-ing with a mask of ones gives us the epsilon.
  # multiplying those together gives us the answer of part A
  def part_one do
    averages =
      input_as_lines()
      |> Enum.map(&parse_line/1)
      |> Nx.tensor()
      |> Nx.mean(axes: [0])
      |> Nx.round()
      |> Nx.to_flat_list()
      |> Enum.map(&trunc/1)

    bit_length = length(averages)
    gamma = Integer.undigits(averages, 2)
    epsilon = Bitwise.bxor(gamma, create_mask(bit_length))

    gamma * epsilon
  end

  defp create_mask(length) do
    mask_as_list = for _ <- 1..length, into: [], do: 1
    Integer.undigits(mask_as_list, 2)
  end
end
