defmodule Aoc21.DayEleven do
  use Aoc21.Elves
  alias Aoc21.DayEleven.Grid
  @max_energy_level 9

  def part_one do
    parse()
    |> iterate_until(fn _grid, iteration -> iteration == 100 end)
    |> then(fn {_grid, flashes, _iterations} -> flashes end)
  end

  def part_two do
    all_zeroes? = fn grid ->
      Enum.all?(grid, fn row -> Enum.all?(row, &(&1 > @max_energy_level)) end)
    end

    parse()
    |> iterate_until(fn grid, _iteration -> all_zeroes?.(grid) end)
    |> then(fn {_grid, _flashes, iterations} -> iterations end)
  end

  defp iterate_until(grid, should_stop?) when is_list(grid),
    do: iterate_until({grid, 0}, 0, should_stop?)

  defp iterate_until({grid, flashes}, iteration, should_stop?) do
    {grid, new_flashes} =
      grid
      |> advance()
      |> simulate_flashes()

    if should_stop?.(grid, iteration),
      do: {grid, flashes, iteration + 1},
      else: iterate_until({grid |> reset(), flashes + new_flashes}, iteration + 1, should_stop?)
  end

  defp simulate_flashes(grid, flashed \\ MapSet.new()) do
    # check if thre's any octopuses that reached their maximum energy level.
    # Once an octopus has reached its maximum energy level it will not be
    # affected by its neighbours until we reset and advance the grid.
    energized_octopuses =
      grid
      |> find_energized_octopuses()
      |> Enum.filter(&(MapSet.member?(flashed, &1) == false))

    case energized_octopuses do
      [] ->
        {grid, MapSet.size(flashed)}

      flashing_octopuses ->
        grid =
          for {x, y} <- flashing_octopuses, reduce: grid do
            grid ->
              # get flashing octopus's neighbours that haven't reached the
              # max energy level just yet.
              grid
              |> Grid.get_neighbours(x, y)
              |> Enum.filter(fn {_coords, value} -> value <= @max_energy_level end)
              |> Enum.reduce(grid, fn {{x, y}, _val}, grid ->
                Grid.update_value(grid, x, y, fn v -> v + 1 end)
              end)
          end

        # keep track of currently flashing octopuses and recurse until there's
        # no more flashing
        flashed = Enum.reduce(flashing_octopuses, flashed, &MapSet.put(&2, &1))
        simulate_flashes(grid, flashed)
    end
  end

  defp reset(grid) do
    for {x, y} <- find_energized_octopuses(grid), reduce: grid do
      grid -> Grid.update_value(grid, x, y, fn _ -> 0 end)
    end
  end

  defp advance(grid) do
    Enum.map(grid, fn line ->
      Enum.map(line, &Kernel.+(&1, 1))
    end)
  end

  defp find_energized_octopuses(grid) do
    {max_x, max_y} = Grid.size(grid)

    for y <- 0..(max_y - 1), x <- 0..(max_x - 1), reduce: [] do
      acc ->
        if Grid.get_value(grid, x, y) > @max_energy_level,
          do: [{x, y}] ++ acc,
          else: acc
    end
  end

  defp parse do
    Enum.map(input_as_lines(), fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&to_int/1)
    end)
  end
end

defmodule Aoc21.DayEleven.Grid do
  def size(grid) do
    height = Enum.count(grid)
    width = grid |> Enum.at(0) |> Enum.count()

    {width, height}
  end

  def get_neighbours(grid, x, y) do
    {max_x, max_y} = size(grid)

    within_bounds = fn {x, y} ->
      x >= 0 && y >= 0 && x < max_x && y < max_y
    end

    candidate_coords = [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1},
      {x + 1, y + 1},
      {x - 1, y - 1},
      {x + 1, y - 1},
      {x - 1, y + 1}
    ]

    candidate_coords
    |> Enum.filter(within_bounds)
    |> Enum.map(fn {x, y} = coords ->
      {coords, get_value(grid, x, y)}
    end)
  end

  def update_value(grid, x, y, value_fun) do
    grid
    |> List.update_at(y, fn row ->
      List.update_at(row, x, value_fun)
    end)
  end

  def get_value(grid, x, y) do
    grid
    |> Enum.at(y)
    |> Enum.at(x)
  end
end
