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

  defp check_winners(boards), do: Enum.filter(boards, &won?/1)

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

  defp play_to_completion(boards, sequence) do
    Enum.reduce_while(sequence, {boards, []}, fn number, {boards, wins} ->
      boards = boards |> mark(number)

      case check_winners(boards) do
        [] ->
          {:cont, {boards, wins}}

        winners ->
          # move winning board to won list, don't consider it part
          # of the game anymore.
          boards = Enum.filter(boards, &(!Enum.member?(winners, &1)))

          # tag all recent winners with the number that made them winning
          new_winners = Enum.map(winners, fn winner -> {winner, String.to_integer(number)} end)

          # and stop the reducer once there's no more boards in the game
          # eg. when all boards have reached a won status
          if length(boards) > 0 do
            {:cont, {boards, wins ++ new_winners}}
          else
            {:halt, {boards, wins ++ new_winners}}
          end
      end
    end)
  end

  # Expected to return 11774
  def part_one do
    [sequence | rest] = input_as_lines()
    [_ | boards] = rest

    sequence = String.split(sequence, ",", trim: true)
    boards = parse_boards(boards)
    {_, wins} = play_to_completion(boards, sequence)
    {winning_board, with_number} = List.first(wins)

    get_unmarked_sum(winning_board) * with_number
  end

  # Expected to return 4495
  def part_two do
    [sequence | rest] = input_as_lines()
    [_ | boards] = rest

    sequence = String.split(sequence, ",", trim: true)
    boards = parse_boards(boards)
    {_, wins} = play_to_completion(boards, sequence)
    {winning_board, with_number} = List.last(wins)

    get_unmarked_sum(winning_board) * with_number
  end
end
