#Modulo encargado de generar un paquete de longitud n.
# Que contiene números elegidos añeatoriamente entre 0 y 1.
defmodule GeneratePackage do

  def new(n) do
    Enum.map(1..n, fn x -> num = :rand.uniform(2)-1 end)
  end

end


#Modulo para ejecutar el algoritmo de la ventana deslizante.
defmodule SlidingWindow do

  # Función encargada de crear un paquete de longitud n,
  # el tamaño de la ventana que será a lo más de longitud n/2
  # y los procesos sender y receiver.
  def new(n) do
    package = GeneratePackage.new(n)
    k = :rand.uniform(div(n, 2))
    sender = spawn(fn -> sender_loop(package, n, k) end)
    recvr = spawn(fn -> recvr_loop(sender) end)
  end

  def sender_loop(package, n, k) do
    :ok
  end

  # Función encargada de iniciar la transmisión.
  def recvr_loop(sender) do
    :ok
  end

end
