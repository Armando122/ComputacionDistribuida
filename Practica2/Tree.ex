defmodule Tree do

  # Función para crear el árbol
  # n es el tamaño del árbol
  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
      {:broadcast, tree, i, caller} -> :ok #aquí puede morir el diccionario de
                                           # procesos o no
      {:convergecast, tree, i, caller} -> :ok #aquí puede morir el diccionario de
                                           # procesos o no
    end
  end

  defp create_tree([], tree, _) do
    tree
  end

  defp create_tree([pid | l], tree, pos) do
    create_tree(l, Map.put(tree, pos, pid), (pos+1))
  end

  def broadcast(tree, n) do
    # n = tamaño del árbol
    servir = principal()
    broadcast_aux(tree, n, 0, servir)
    send(tree[0],{:broadcast, tree, n, servir})
  end

  #Función recursiva auxiliar para propagar
  #el mensaje broadcast.
  defp broadcast_aux(tree, n, act,pid) do
    m = act
    izq = (2*m) + 1
    der = (2*m) + 2
    cond do
      Map.has_key?(tree, izq) and Map.has_key?(tree, der) ->
        broadcast_aux(tree,n,izq,pid)
        broadcast_aux(tree,n,der,pid)
      Map.has_key?(tree, izq) ->
        broadcast_aux(tree,n,izq,pid)
      Map.has_key?(tree, der) ->
        broadcast_aux(tree,n,der,pid)
      true -> send(pid, {:status, m, tree[m]})
    end
  end

  #Función para crear el nodo principal al que
  #se le enviará la información de broadcast
  # o convergecast.
  defp principal() do
    spawn(fn -> estado([]) end)
  end

  defp estado(lista) do
    receive do
      {:status, m, pid} -> estado(lista++[{m,pid}])
      {:get, pid} -> send(pid,{lista})
    end
  end

  def convergecast(tree, n) do
    # Donde n es el tamaño del árbol
    #Aquí va su código.
    :ok
  end

end
