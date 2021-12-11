defmodule Consensus do

  def create_consensus(n) do
    #Crear n hilos pero cada uno de esos hilos va
    #a escoger un número completamente al azar.
    #El deber del estudiante es completar la función loop
    #para que al final de un número de ejecuciones de esta,
    #todos los hilos tengan el mismo número, el cual va a ser enviado vía un
    #mensaje al hilo principal.
    Enum.map(1..n, fn _ ->
      spawn(fn -> loop(:start, 0, :rand.uniform(10), []) end)
    end)
  end

  #Función loop que recibe el estado del proceso, el valor
  # elegido, la probabilidad de fallar y la lista de vecinos.
  defp loop(state, value, miss_prob,vecinos) do
    #inicia código inamovible.
    if(state == :fail) do
      loop(state, value, miss_prob,vecinos)
    end

    # Termina código inamovible.
    receive do
      {:get_value, caller} ->
        send(caller, value) #No modificar.

      {:vecinos,list} -> loop(state,value,miss_prob,list)

      {:add,val} ->
        if val<value do
          loop(state,val,miss_prob,vecinos)
        else
          loop(state,value,miss_prob,vecinos)
        end

    after
      1000 -> :ok #Aquí analizar porqué está esto aquí.

    end

    case state do
      :start ->
        chosen = :rand.uniform(10000)

        if(rem(chosen, miss_prob) == 0) do
          loop(:fail, chosen, miss_prob,vecinos)
        else
          Process.sleep(5000)
          loop(:active, chosen, miss_prob,vecinos)
        end

      :fail -> loop(:fail, value, miss_prob,vecinos)

      #Envío de su propuesta a los demás procesos
      :active ->
        for pid <- vecinos do
          send(pid,{:add,value})
        end
        loop(:wait,value,miss_prob,vecinos)

      # Mensaje para que el proceso se siga ejecutando
      # mientras recibe las propuestas.
      :wait -> loop(state,value,miss_prob,vecinos)

    end
  end

  def consensus(processes) do

    # Establecemos la lista de vecinos de cada proceso.
    for v <- processes do
      send(v, {:vecinos, List.delete(processes,v)})
    end

    Process.sleep(10000)

    # Obtenemos el valor que eligió cada proceso.
    for pid <- processes do
      send(pid, {:get_value, self()})
      receive do
        value -> IO.puts(inspect(pid) <> " eligió: " <> inspect(value))
      after
        100 -> IO.puts(inspect(pid) <> " fallido" )
      end
    end

  end

end
