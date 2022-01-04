defmodule Aoc21.DayTwelve do
  use Aoc21.Elves
  alias Aoc21.DayTwelve.Graph

  def part_one do
    graph = input_as_lines() |> Graph.new()
    find_paths(graph) |> Enum.count()
  end

  defp find_paths(graph) do
    chunk_fn = fn
      "end" = node, path -> {:cont, Enum.reverse([node | path]), []}
      node, path -> {:cont, [node | path]}
    end

    after_fn = fn
      [] -> {:cont, []}
      path -> {:cont, path, []}
    end

    graph
    |> walk("start")
    |> Enum.chunk_while([], chunk_fn, after_fn)
  end

  defp walk(graph, start_vertex, visited \\ [])

  defp walk(_graph, "end", visited),
    do: Enum.reverse(["end"] ++ visited)

  defp walk(graph, start_vertex, visited) do
    small_cave? = fn cave ->
      cave
      |> String.to_charlist()
      |> List.first()
      |> then(&(&1 in ?a..?z))
    end

    for next <- graph |> Map.get(start_vertex), reduce: [] do
      acc ->
        path =
          if small_cave?.(next) && Enum.member?(visited, next),
            do: nil,
            else: walk(graph, next, [start_vertex] ++ visited)

        case path do
          nil -> acc
          [] -> acc
          path -> path ++ acc
        end
    end
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
