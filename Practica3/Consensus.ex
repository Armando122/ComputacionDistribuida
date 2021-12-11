defmodule Consensus do

  def create_consensus(n) do
    #Crear n hilos pero cada uno de esos hilos va
    #a escoger un número completamente al azar.
    #El deber del estudiante es completar la función loop
    #para que al final de un número de ejecuciones de esta,
    #todos los hilos tengan el mismo número, el cual va a ser enviado vía un
    #mensaje al hilo principal.
    Enum.map(1..n, fn _ ->
      spawn(fn -> loop(:start, 0, :rand.uniform(10)) end)
    end)

    #Función para indexar los hilos
    indexa(Enum.map(1..n, fn _ ->
          spawn(fn -> loop(:start, 0, :rand.uniform(10)) end)
        end), %{}, 0)

    #Agregar código es valido
  end

  # Función auxiliar indexa para indexar los procesos
  # en un diccionario.
  defp indexa([], procesos, _) do
    procesos
  end

  # Función auxiliar indexa para indexar los procesos
  # en un diccionario. (Sobrecarga de método)
  defp indexa([pid | l], procesos, pos) do
    indexa(l, Map.put(procesos, pos, pid), (pos+1))
  end

  # Función loop que recibe como último parametro
  # una lista correspondiente a los vecinos del proceso.
  defp loop(state, value, miss_prob) do
    #inicia código inamovible.
    if(state == :fail) do
      loop(state, value, miss_prob)
    end

    # Termina código inamovible.
    receive do
      {:get_value, caller} ->
	      send(caller, value) #No modificar.
        #Aquí se pueden definir más mensajes.
    after
      1000 -> :ok #Aquí analizar porqué está esto aquí.

    end
    case state do
      :start ->
        chosen = :rand.uniform(10000)

        if(rem(chosen, miss_prob) == 0) do
          loop(:fail, chosen, miss_prob)
        else
          loop(:active, chosen, miss_prob)
        end

      :fail -> loop(:fail, value, miss_prob)

      #Envío de su propuesta a los demás procesos
      :active ->
        for pid <- vecinos do
          send(pid,{:add,value})
          loop(:wait,value,miss_prob)
        end

      #Mensaje para almacenar las propuestas recibidas.
      #Y tomar una decisión después de segundos.
      :wait -> :ok

    end
  end

  def consensus(processes) do
    # Establecemos la lista de vecinos de cada proceso.
    for v <- processes do
      send(v, {:add, List.delete(processes,v)})
    end

    Process.sleep(10000)

    # Obtenemos el valor que eligió cada proceso.
    for pid <- processes do
      send(pid, {:get_value, self()})
      receive do
        value -> IO.puts(inspect(p), " eligió: ", inspect(value))
      after
        100 -> IO.puts(inspect(p), " fallido" )
      end
    end

  end

end
