defmodule Tree do

  # Función para crear el árbol
  # n es el tamaño del árbol
  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
      {:broadcast, tree, i, caller} -> broadcast_aux(tree,i,caller)
      {:convergecast, tree, i, caller} -> convergecast_per_node(tree,i,caller, []) #aquí puede morir el diccionario de
                                                                                   #procesos o no
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
    send(tree[0],{:broadcast, tree, 0, servir})
  end

  #Función auxiliar para propagar el mensaje broadcast.
  defp broadcast_aux(tree, act, pid) do
    m = act
    izq = (2*m) + 1
    der = (2*m) + 2
    cond do
      Map.has_key?(tree, izq) and Map.has_key?(tree, der) ->
        pidIzq = tree[izq]
        pidDer = tree[der]
        send(pidIzq,{:broadcast, tree, izq, pid})
        send(pidDer,{:broadcast, tree, der, pid})
      Map.has_key?(tree, izq) ->
        pidIzq = tree[izq]
        send(pidIzq,{:broadcast, tree, izq, pid})
      Map.has_key?(tree, der) ->
        pidDer = tree[der]
        send(pidDer,{:broadcast, tree, der, pid})
      true -> send(pid, {tree[m], :ok})
      send(pid,{:get})
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
      {m, :ok} -> estado(lista++[{m,:ok}])
      {:get} -> IO.puts("#{inspect(lista)}")
      estado(lista)
    end
  end

  def convergecast(tree, n) do
    # Donde n es el tamaño del árbol
    #Aquí va su código.
    #Paso 1, situarme en las hojas

    hojas=(ceil n / 2)
    Enum.each((n-hojas)..(n-1),fn x -> send(tree[x], {:convergecast,tree,x, self()}) end)
    recibidos = receive do
      w -> w
    end
    outgoing = Tuple.delete_at(Tuple.append(recibidos, elem(recibidos, 0)), 0)
    IO.puts("#{inspect(outgoing)}")
    recibidos
  end

  def convergecast_per_node(tree, x, caller, registro)do
    padre = padre(x)
    hijos = verifica_hijos(tree,x)
    registro++hijos
    num_hijos = Enum.count(hijos)

    cond do
      x == 0 -> #soy raíz
        send(caller, {:ok,tree[0]})
      num_hijos == 0 -> #Es la hoja
        send(tree[padre], {:convergecast, tree, padre, caller})
      Enum.count(tree) == Enum.count(registro) && tree[padre] != nil ->
        send(tree[padre], {:convergecast, tree, padre, caller})
        tree[padre] == nil ->
          true
    end
    registro
  end

  defp reinicia_nodos(tree)do
    Enum.each(Map.values(tree), fn proceso-> send(proceso, :reset)end)
  end

  defp verifica_hijos(tree,x) do
    l= []
    if tree[derecho(x)] != nil do
      l++[{derecho(x),tree[derecho(x)]}]
    end

    if tree[izquierdo(x)] != nil do
      l++[ {izquierdo(x),tree[izquierdo(x)]}]
    end
    l
  end

  def izquierdo n do
    (2*n)+1
  end

  def derecho n do
    (2*n)+2
  end

  def padre n do
    floor((n-1)/2)
  end
end
