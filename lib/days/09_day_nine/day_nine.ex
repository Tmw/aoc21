defmodule Aoc21.DayNine do
  use Aoc21.Elves

  # expected to return 548 (15 with the example input)
  def part_one do
    grid = input_as_lines() |> parse_grid()
    only_lowpoints = &elem(&1, 1)

    mark_low_points(grid)
    |> Enum.filter(only_lowpoints)
    |> Enum.map(&(elem(&1, 0) + 1))
    |> Enum.sum()
  end

  # finds the lowest points by comparing each coordinate
  # with its up-to-four adjecent neighbours.
  defp mark_low_points(grid) do
    height = grid |> Enum.count()
    width = grid |> Enum.at(0) |> Enum.count()

    for y <- 0..(height - 1), x <- 0..(width - 1) do
      neighbouring_cells = get_neighbours(grid, x, y)
      {curr_value, _} = get_value(grid, x, y)

      lowest? = Enum.all?(neighbouring_cells, fn {val, _} -> val > curr_value end)
      {curr_value, lowest?}
    end
  end

  defp get_value(grid, x, y) do
    grid
    |> Enum.at(y)
    |> Enum.at(x)
  end

  # get up to four neighbouring cells given a coordinate.
  defp get_neighbours(grid, x, y) do
    neighbouring_coordinates = [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]

    # do a quick bounds check on the possible neighbouring coordinates,
    # reject any that are out of bounds.
    max_x = grid |> Enum.at(0) |> Enum.count()
    max_y = grid |> Enum.count()

    bounds_check = fn {x, y} ->
      x >= 0 && x < max_x && y >= 0 && y < max_y
    end

    neighbouring_coordinates
    |> Enum.filter(bounds_check)
    |> Enum.map(fn {x, y} -> get_value(grid, x, y) end)
  end

  defp parse_grid(input) do
    to_digits = fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(&to_int/1)
    end

    wrap = fn heights ->
      Enum.map(heights, &{&1, true})
    end

    input
    |> Enum.map(to_digits)
    |> Enum.map(wrap)
  end
end
