defmodule Aoc21.DayNine do
  use Aoc21.Elves
  alias Aoc21.DayNine.Grid

  # Objective for part one:
  # finding all low points, what is the sum of their risk level.
  # risk level = 1 + the lowpoint's value.
  # expected to return 548 (15 with the example input)
  def part_one do
    grid = input_as_lines() |> parse()

    find_low_points(grid)
    |> Enum.map(&(elem(&1, 2) + 1))
    |> Enum.sum()
  end

  # Objective for part two:
  # Find the three largest basins in the map and multiply their area
  # Assumption is that the lowpoints in part one are the "end points" of each unique basin.
  # We can use those coordinates and do a flood fill from there to find their area?
  def part_two do
    grid = input_as_lines() |> parse()

    grid
    |> find_low_points()
    |> Enum.map(fn {x, y, v} ->
      measure_basin(grid, [{x, y, v}]) |> MapSet.size()
    end)
    |> Enum.sort(&(&1 > &2))
    |> Enum.take(3)
    |> Enum.product()
  end

  # finds the lowest points by comparing each coordinate
  # with its up-to-four adjecent neighbours.
  defp find_low_points(grid) do
    {width, height} = Grid.get_dimensions(grid)

    for y <- 0..(height - 1), x <- 0..(width - 1), reduce: [] do
      low_points ->
        current_value = Grid.get_value(grid, x, y)

        grid
        |> Grid.get_neighbours(x, y)
        |> Enum.all?(fn {_x, _Y, value} -> value > current_value end)
        |> then(fn lowest? ->
          if lowest?, do: low_points ++ [{x, y, current_value}], else: low_points
        end)
    end
  end

  defp measure_basin(grid, candidates, visited \\ MapSet.new())
  defp measure_basin(_grid, [], visited), do: visited

  defp measure_basin(grid, [{x, y, _v} | candidates], visited) do
    visited = MapSet.put(visited, {x, y})

    unvisited = fn {x, y, _v} ->
      MapSet.member?(visited, {x, y}) == false
    end

    not_nine = fn {_x, _y, v} ->
      v != 9
    end

    new_candidates =
      grid
      |> Grid.get_neighbours(x, y)
      |> Enum.filter(unvisited)
      |> Enum.filter(not_nine)

    measure_basin(grid, candidates ++ new_candidates, visited)
  end

  defp parse(input) do
    to_digits = fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(&to_int/1)
    end

    Enum.map(input, to_digits)
  end
end

defmodule Aoc21.DayNine.Grid do
  def get_dimensions(grid) do
    width = grid |> Enum.at(0) |> Enum.count()
    height = grid |> Enum.count()
    {width, height}
  end

  def get_value(grid, x, y) do
    grid
    |> Enum.at(y)
    |> Enum.at(x)
  end

  # get up to four neighbouring grid cells given a coordinate.
  def get_neighbours(grid, x, y) do
    neighbouring_coordinates = [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]

    # do a quick bounds check on the possible neighbouring coordinates,
    # reject any that are out of bounds.
    {max_x, max_y} = get_dimensions(grid)

    bounds_check = fn {x, y} ->
      x >= 0 && x < max_x && y >= 0 && y < max_y
    end

    neighbouring_coordinates
    |> Enum.filter(bounds_check)
    |> Enum.map(fn {x, y} -> {x, y, get_value(grid, x, y)} end)
  end
end
