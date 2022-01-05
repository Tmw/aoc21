defmodule Aoc21.DayTwelve do
  use Aoc21.Elves
  alias Aoc21.DayTwelve.Graph
  alias Aoc21.DayTwelve.Graph.TraversalStrategy

  def part_one do
    graph = input_as_lines() |> Graph.new()

    graph
    |> find_paths(strategy: TraversalStrategy.SingleVisit)
    |> Enum.count()
  end

  def part_two do
    graph = input_as_lines() |> Graph.new()

    graph
    |> find_paths(strategy: TraversalStrategy.SingleRevisit)
    |> Enum.count()
  end

  defp find_paths(graph, strategy: strategy) do
    chunk_fn = fn
      "end" = node, path -> {:cont, Enum.reverse([node | path]), []}
      node, path -> {:cont, [node | path]}
    end

    after_fn = fn
      [] -> {:cont, []}
      path -> {:cont, path, []}
    end

    graph
    |> walk("start", strategy)
    |> Enum.chunk_while([], chunk_fn, after_fn)
  end

  defp walk(
         graph,
         start_vertex,
         traversal_strategy,
         visited \\ []
       )

  defp walk(_graph, "end", _traversal_strategy, visited),
    do: Enum.reverse(["end"] ++ visited)

  defp walk(graph, start_vertex, traversal_strategy, visited) do
    for next <- graph |> Map.get(start_vertex), reduce: [] do
      acc ->
        path =
          if traversal_strategy.legal_move?(start_vertex, next, visited),
            do: walk(graph, next, traversal_strategy, [start_vertex] ++ visited),
            else: nil

        case path do
          nil -> acc
          [] -> acc
          path -> path ++ acc
        end
    end
  end
end

defmodule Aoc21.DayTwelve.Graph.TraversalStrategy do
  @moduledoc """
  behaviour that describes a graph traversal strategy by determining wether 
  moving to a given node from a current node and a given travel history 
  would be legal or not.
  """
  @typep graph_node :: String.t()
  @callback legal_move?(
              current_node :: graph_node,
              considered_node :: graph_node,
              history :: [graph_node]
            ) :: boolean()
end

defmodule Aoc21.DayTwelve.Graph.TraversalStrategy.SingleVisit do
  @moduledoc """
  Using this traversal strategy ensures we're visiting the small caves once.
  """
  @behaviour Aoc21.DayTwelve.Graph.TraversalStrategy

  def legal_move?(_current_node, "start", _history), do: false

  def legal_move?(_current_node, considered_node, history) do
    is_revisit? = small_cave?(considered_node) && Enum.member?(history, considered_node)
    not is_revisit?
  end

  defp small_cave?(cave) do
    cave
    |> String.to_charlist()
    |> List.first()
    |> then(&(&1 in ?a..?z))
  end
end

defmodule Aoc21.DayTwelve.Graph.TraversalStrategy.SingleRevisit do
  @moduledoc """
  Using this traversal strategy ensures we're visiting one small cave 
  at most twice.
  """
  @behaviour Aoc21.DayTwelve.Graph.TraversalStrategy

  def legal_move?(_current_node, "start", _history), do: false

  def legal_move?(current_node, considered_node, history) do
    checker_fn = fn
      [2, 1 | _rest] -> true
      [1, 1 | _rest] -> true
      [1] -> true
      _ -> false
    end

    # if we would travel like this, how many times did we visit a small
    # cave twice?
    ([considered_node, current_node] ++ history)
    |> Enum.filter(&small_cave?/1)
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort(:desc)
    |> then(checker_fn)
  end

  defp small_cave?(cave) do
    cave
    |> String.to_charlist()
    |> List.first()
    |> then(&(&1 in ?a..?z))
  end
end

defmodule Aoc21.DayTwelve.Graph do
  def new(input) do
    input
    |> parse_edges()
    |> parse_graph()
  end

  defp parse_edges(input) do
    input |> Enum.map(&(String.split(&1, "-") |> List.to_tuple()))
  end

  defp parse_graph(edges) do
    Enum.reduce(edges, %{}, fn {vertex_a, vertex_b}, graph ->
      graph
      |> add_edge(vertex_a, vertex_b)
      |> add_edge(vertex_b, vertex_a)
    end)
  end

  defp add_edge(graph, vertex_a, vertex_b) do
    {_, graph} =
      Map.get_and_update(graph, vertex_b, fn
        nil -> {nil, [vertex_a]}
        vertices -> {vertices, [vertex_a] ++ vertices}
      end)

    graph
  end
end
