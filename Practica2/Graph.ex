defmodule Graph do

  #Infinito esta dado por -1
  # Envías distancia mas 1
  #Distancia inicial es 0
  def new(n) do
    create_graph(Enum.map(1..n, fn _ -> spawn(fn -> loop(-1) end) end), %{}, n)
  end

  defp loop(state) do
    receive do
      {:bfs, graph, new_state} ->
        cond do
          new_state < state || state == -1 ->
            Enum.each(Map.get(graph, self()), fn proceso -> send(proceso, {:bfs, graph, new_state+1}) end)
            loop(new_state)
          true ->
            loop(state)
        end

      {:dfs, graph, new_state} ->
        cond do
          true ->
            sinExplorar = Map.get(graph, self())
            proceso = Enum.random(sinExplorar)
            graph = Map.put(graph, self(), Map.delete(sinExplorar, proceso))
            loop(state)
        end

      {:get_state, caller} -> send(caller, {self, state}) #Estos mensajes solo los manda el main.
    end
  end

  defp create_graph([], graph, _) do
    graph
  end

  defp create_graph([pid | l], graph, n) do
    g = create_graph(l, Map.put(graph, pid, MapSet.new()), n)
    e = :rand.uniform(div(n*(n-1), 2))
    create_edges(g, e)
  end

  defp create_edges(graph, 0) do
    graph
  end

  defp create_edges(graph, n) do
    nodes = Map.keys(graph)
    create_edges(add_edge(graph, Enum.random(nodes), Enum.random(nodes)), n-1)
  end

  defp add_edge(graph, u, v) do
    cond do
      u == nil or v == nil -> graph
      u == v -> graph
      true ->
	u_neighs = Map.get(graph, u)
	new_u_neighs = MapSet.put(u_neighs, v)
	graph = Map.put(graph, u, new_u_neighs)
	v_neighs = Map.get(graph, v)
	new_v_neighs = MapSet.put(v_neighs, u)
	Map.put(graph, v, new_v_neighs)
    end
  end

  def random_src(graph) do
    Enum.random(Map.keys(graph))
  end

  defp unified(graph, src, mode) do
    send(src, {mode, graph, 0})
    Process.sleep(5000)
    Enum.each(Map.keys(graph), fn proceso -> send(proceso, {:get_state, self()}) end)
    n = length(Map.keys(graph))
    Enum.map(1..n, fn _ -> receive do x -> x end end)
  end

  #Llevar una cuenta de los padres y saber si
  # un vértice ya recibió mensaje, eso puede verse en
  # loop.
  def bfs(graph, src) do
    unified(graph, src, :bfs)
  end

  def bfs(graph) do
    bfs(graph, random_src(graph))
  end

  def dfs(graph, src) do
    unified(graph, src, :dfs)
  end

  def dfs(graph) do
    dfs(graph, random_src(graph))
  end

end
