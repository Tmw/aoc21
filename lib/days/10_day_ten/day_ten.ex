defmodule Aoc21.DayTen do
  use Aoc21.Elves

  @pairs %{
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">"
  }

  @syntax_error_scores %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
  }

  def part_one do
    parsed()
    |> analyze_input()
    |> Enum.filter(&is_tuple/1)
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&Map.get(@syntax_error_scores, &1))
    |> Enum.sum()
  end

  defp analyze_input(input) do
    input
    |> Enum.map(&parse_symbols/1)
    |> Enum.map(&apply_instructions/1)
  end

  defp parse_symbols(symbols) do
    Enum.map(symbols, &parse_symbol/1)
  end

  defp apply_instructions(list, stack \\ [])
  defp apply_instructions([], stack), do: stack

  defp apply_instructions([{:push, symbol} | backlog], stack),
    do: apply_instructions(backlog, [symbol] ++ stack)

  defp apply_instructions([{:pop, symbol_a} | backlog], [symbol_b | stack]) do
    if symbol_a != Map.get(@pairs, symbol_b),
      do: {:illegal_symbol, symbol_a},
      else: apply_instructions(backlog, stack)
  end

  defp parse_symbol(symbol) do
    opening_symbols = @pairs |> Map.keys()
    closing_symbols = @pairs |> Map.values()

    cond do
      Enum.member?(opening_symbols, symbol) -> {:push, symbol}
      Enum.member?(closing_symbols, symbol) -> {:pop, symbol}
    end
  end

  defp parsed do
    input_as_lines()
    |> Enum.map(&String.graphemes/1)
  end
end
