defmodule Aoc21.DayFive do
  use Aoc21.Elves
  @segment_pattern ~r/,|\s->\s/

  def part_one do
    segments =
      input_as_lines()
      |> parse_segments()
      |> only_orthogonals()

    result =
      segments
      |> plot_lines()
      |> count_busy_spots()
  end

  defp count_busy_spots(plotted_lines) do
    more_than_once? = fn
      {_, x} when x > 1 -> true
      _ -> false
    end

    plotted_lines
    |> Enum.filter(more_than_once?)
    |> Enum.count()
  end

  # plot_lines takes the various segments and plots them on a `map`
  # that maps between coordinate and the number of 'visits' on that coord
  defp plot_lines(segments) do
    segments
    |> Enum.flat_map(&expand_segment/1)
    |> Enum.reduce(%{}, fn coord, acc ->
      Map.update(acc, coord, 1, &(&1 + 1))
    end)
  end

  # expanding a segment means returning all intermediate points
  # so they can be used in the final calculation. Note this will only work
  # for orthogonal segments currently?
  defp expand_segment({{x1, y1}, {x2, y2}}) do
    for x <- x1..x2, y <- y1..y2, do: {x, y}
  end

  defp parse_segments(segments) do
    segments
    |> Enum.flat_map(&Regex.split(@segment_pattern, &1))
    |> Enum.chunk_every(4)
    |> Enum.map(&parse_segment/1)
  end

  defp parse_segment([x1, y1, x2, y2]) do
    {
      {to_int(x1), to_int(y1)},
      {to_int(x2), to_int(y2)}
    }
  end

  # a line segment is considered orthogonal when both points
  # share either the same X or Y coordinate.
  defp only_orthogonals(segments) do
    is_ortogonal? = fn
      {{x, _}, {x, _}} -> true
      {{_, y}, {_, y}} -> true
      _ -> false
    end

    Enum.filter(segments, is_ortogonal?)
  end
end
