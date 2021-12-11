defmodule Aoc21.DayTwo do
  use Aoc21.Elves

  @part_one_applyer Aoc21.DayTwo.PartOneApplyer
  @part_two_applyer Aoc21.DayTwo.PartTwoApplyer

  # expected to return 1762050
  def part_one do
    position = %{depth: 0, forward: 0}

    position =
      input_as_lines()
      |> Enum.map(&parse_instruction/1)
      |> Enum.reduce(position, &@part_one_applyer.apply_instruction/2)

    position.depth * position.forward
  end

  # expected to return 1855892637
  def part_two do
    position = %{depth: 0, forward: 0, aim: 0}

    position =
      input_as_lines()
      |> Enum.map(&parse_instruction/1)
      |> Enum.reduce(position, &@part_two_applyer.apply_instruction/2)

    position.depth * position.forward
  end

  defp parse_instruction("forward " <> delta), do: {:forward, to_int(delta)}
  defp parse_instruction("down " <> delta), do: {:down, to_int(delta)}
  defp parse_instruction("up " <> delta), do: {:up, to_int(delta)}
  defp parse_instruction(_), do: :unknown
end

defmodule Aoc21.DayTwo.Applyer do
  @callback apply_instruction({atom(), integer()}, pos :: map()) :: map()
end

defmodule Aoc21.DayTwo.PartOneApplyer do
  @behaviour Aoc21.DayTwo.Applyer
  def apply_instruction({:forward, delta}, pos), do: Map.update!(pos, :forward, &(&1 + delta))
  def apply_instruction({:down, delta}, pos), do: Map.update!(pos, :depth, &(&1 + delta))
  def apply_instruction({:up, delta}, pos), do: Map.update!(pos, :depth, &(&1 - delta))
end

defmodule Aoc21.DayTwo.PartTwoApplyer do
  @behaviour Aoc21.DayTwo.Applyer

  def apply_instruction({:down, delta}, pos), do: Map.update!(pos, :aim, &(&1 + delta))
  def apply_instruction({:up, delta}, pos), do: Map.update!(pos, :aim, &(&1 - delta))

  def apply_instruction({:forward, delta}, pos) do
    pos
    |> Map.update!(:forward, &(&1 + delta))
    |> Map.update!(:depth, &(&1 + delta * pos.aim))
  end
end
