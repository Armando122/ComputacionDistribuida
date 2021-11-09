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

    cond do
      Map.has_key?(tree, (2*n) + 1) and Map.has_key?(tree, (2*n) + 2) ->
        pidIzq = tree[(2*n) + 1]
        send(pidIzq, {:broadcast, tree, ((2*n) + 1), tree[n]})
        #pidDer = tree[(2*n) + 2]
        #send(pidDer, {:broadcast, tree, ((2*n) + 2), self()})
      Map.has_key?(tree, (2*n) + 1) ->
        "Tiene hijo derecho"
      Map.has_key?(tree, (2*n) + 2) ->
        "Tiene hijo izquierdo"
      true -> "No tiene hijos"
    end
  end

  def convergecast(tree, n) do
    # Donde n es el tamaño del árbol
    #Aquí va su código.
    :ok
  end

end
