defmodule Graph do

  def new(n) do
      create_graph(Enum.map(1..n, fn _ -> spawn(fn -> loop(-1) end) end), %{}, n)
  end

  defp loop(state) do
    receive do
      {:bfs, graph, new_state} -> state = if new_state < state || state == -1 do  new_state else state end
                                  list_vec = Map.get(graph, self())
                                  Enum.map(list_vec, fn x -> send(x, {:bfs, graph, state + 1})end)
                                  loop(state)

      {:dfs, graph, new_state} -> distance = if state == -1 do state+1 end
        list_vec = Map.get(graph, self())
        Enum.map(list_vec, fn x -> send(x, {:bfs, graph, distance})end)
        loop(distance)

        {:get_state, caller} -> #Estos mensajes solo los manda el main.
        if state == -1 do
                      Process.sleep(5000)
                      send(self, {:get_state, caller})
                      loop(state)
                     else
                       send(caller, {self, state})
        end
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

  def bfs(graph, src) do
    send(src, {:bfs, graph, 0})
    nodos = Map.keys(graph)
    tamaño = map_size(graph)
    aux(0, tamaño,nodos)
    Enum.map(Map.keys(graph), fn x -> send(x,{:get_state,self})
      receive do
        {pid, state} -> {pid, state}
      end
    end)
  end

  def aux(x,long,nodos) do
    if x < long do
      send(Enum.at(nodos,x), {:get_state, self})
      aux(x+1,long,nodos)
    end
  end

  def bfs(graph) do
    bfs(graph, random_src(graph))
  end

  def dfs(graph, src) do
    send(src, {:dfs, graph, 0})
    nodos = Map.keys(graph)
    tamaño = map_size(graph)
    aux(0, tamaño,nodos)
    Enum.map(Map.keys(graph), fn x -> send(x,{:get_state,self})
      receive do
        {pid, state} -> {pid, state}
      end
    end)
  end

  def dfs(graph) do
    dfs(graph, random_src(graph))
  end
end
