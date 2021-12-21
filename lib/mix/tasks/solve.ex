defmodule Mix.Tasks.Solve do
  @moduledoc "Solve the aoc puzzles"
  use Mix.Task

  @puzzles [
    Aoc21.DayOne,
    Aoc21.DayTwo,
    Aoc21.DayThree,
    Aoc21.DayFour
  ]

  @shortdoc "Solve the aoc puzzles"
  def run(_) do
    results =
      Enum.map(@puzzles, fn puzzle ->
        [
          get_module_name(puzzle),
          puzzle.part_one(),
          puzzle.part_two()
        ]
      end)

    # inject column headers
    rows = [["Day", "Part one", "Part two"]] ++ results
    column_widths = get_column_widths(rows)
    format_row = row_formatter(column_widths)

    # write header
    [header | rows] = rows

    header_row =
      header
      |> format_row.()
      |> Enum.join(" | ")

    IO.puts(header_row)

    # divider line
    length = String.length(header_row)
    IO.puts(String.duplicate("=", length))

    rows
    |> Enum.map(format_row)
    |> Enum.map(&Enum.join(&1, " | "))
    |> Enum.map(&IO.write("#{&1}\n"))
  end

  defp row_formatter(column_widths) do
    fn row ->
      row
      |> Enum.zip(column_widths)
      |> Enum.map(fn {content, width} ->
        String.pad_leading("#{content}", width)
      end)
    end
  end

  defp get_column_widths(rows) do
    rows
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&content_width/1)
    |> Enum.map(&Enum.max/1)
  end

  defp content_width(content) do
    content
    |> Enum.map(&String.length("#{&1}"))
  end

  defp get_module_name(module) do
    module
    |> to_string()
    |> String.split(".")
    |> List.last()
  end
end
