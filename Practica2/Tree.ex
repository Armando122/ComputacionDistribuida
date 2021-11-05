defmodule Tree do

  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
      {:broadcast, tree, i, caller} -> :ok #Aquí va su código.
      {:convergecast, tree, i, caller} -> :ok #Aquí va su código.
    end
  end

  defp create_tree([], tree, _) do
    tree
  end

  defp create_tree([pid | l], tree, pos) do
    create_tree(l, Map.put(tree, pos, pid), (pos+1))
  end

  def broadcast(tree, n) do
    cond do
      Map.has_key?(tree, (2*n) + 1) and Map.has_key?(tree, (2*n) + 2) ->
        "Tiene dos hijos"
      Map.has_key?(tree, (2*n) + 1) ->
        "Tiene hijo derecho"
      Map.has_key?(tree, (2*n) + 2) ->
        "Tiene hijo izquierdo"
      true -> "No tiene hijos"
    end
  end

  def convergecast(tree, n) do
    #Aquí va su código.
    :ok
  end

end
