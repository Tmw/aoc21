defmodule Aoc21.DayFour do
  use Aoc21.Elves
  @board_size 5

  # let's asume we can safely call to_atom here and we wont blow up our atom table 😏
  defp to_marked_atom_tuple(item), do: {String.to_atom(item), false}

  # take input lines and convert to a list of Keyword lists mapping
  # their "marked" status to their number.
  defp parse_boards(input) do
    input
    |> Enum.flat_map(&String.split(&1, " ", trim: true))
    |> Enum.map(&to_marked_atom_tuple/1)
    |> Enum.chunk_every(@board_size * @board_size)
    |> Enum.map(&Keyword.new/1)
  end

  defp mark(boards, number) when is_binary(number), do: mark(boards, String.to_atom(number))

  defp mark(boards, number) do
    Enum.map(boards, fn board ->
      Keyword.replace(board, number, true)
    end)
  end

  defp check_winner(boards), do: Enum.find(boards, &won?/1)

  defp won?(board) do
    is_winning_row? = fn row ->
      Enum.all?(row, &elem(&1, 1))
    end

    wins_horizontally =
      board
      |> Enum.chunk_every(@board_size)
      |> Enum.any?(is_winning_row?)

    wins_vertically =
      board
      |> Enum.chunk_every(@board_size)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.any?(is_winning_row?)

    wins_horizontally || wins_vertically
  end

  defp get_unmarked_sum(board) do
    board
    |> Enum.reduce(0, fn
      {val, false}, acc -> acc + String.to_integer(Atom.to_string(val))
      {_, true}, acc -> acc
    end)
  end

  def part_one do
    [sequence | rest] = input_as_lines()
    [_ | boards] = rest

    sequence = String.split(sequence, ",", trim: true)
    boards = parse_boards(boards)

    {winning_board, with_number} =
      Enum.reduce_while(sequence, boards, fn number, boards ->
        boards = boards |> mark(number)

        case check_winner(boards) do
          nil -> {:cont, boards}
          winner -> {:halt, {winner, number}}
        end
      end)

    unmarked_sum = get_unmarked_sum(winning_board)
    winning_number = with_number |> String.to_integer()

    unmarked_sum * winning_number
  end
end
