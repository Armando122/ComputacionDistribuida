defmodule GeneratePackage do

  def new(n) do
    Enum.map(1..n, fn x -> num = :rand.uniform(2)-1 end)
  end

end

defmodule SlidingWindow do

  def new(n) do
    package = GeneratePackage.new(n)
    k = :rand.uniform(div(n, 2))
    sender = spawn(fn -> sender_loop(package, n, k) end)
    recvr = spawn(fn -> recvr_loop(sender) end)

    s = for_receive(sender)
    IO.inspect(s)
    r = for_receive(recvr)
    IO.inspect(r)
    if r==s do
      :ok
    else
      :nok
    end

  end

  def for_receive(sender) do
    send(sender, {:final, self()})

    receive do
      {:s, container}-> container
    after
      3000 -> "Falla en la recepción"
    end
  end

  def atom_to_int(att) do
    String.to_integer(Atom.to_string(att))
  end

  def int_to_atom(i) do
    String.to_atom(Integer.to_string(i))
  end


  def sender_loop(package, n, k) do
    values=Enum.map(0..n-1, fn x -> {int_to_atom(x+1) , Enum.at(package,x) } end)
    f_stp=spawn(fn -> recvr_loop(self()) end)

    send(f_stp, :start)

    axl_send(values, n,k, self(),f_stp)
    receive do
      {:ready, pij}-> axl_send(values, n-k, n, self(),pij)#Receiver está preparado para recibir
      {:c, :"0", pij} -> send(pij, :end)
      {:c, index, pij} -> axl_send(values, index-k, index-1, self(), pij)
      {:final, sender} -> send(sender, {:s, package})
    after
      1000 -> axl_send(values, n-k, n, self(), f_stp)#Reiniciamos el envío
    end
  end

  def axl_send(values, i, j, pId, pij) do
    sender=pId
    recvr=pij
    max_tras=i#cota inferior de la ventana
    max_ini=j #cota superior de la ventana

    Enum.map(max_tras..max_ini, fn x -> send(recvr,  {int_to_atom(x), values[int_to_atom(x)], j}) end)

  end




  def recvr_loop(sender) do
    saver=spawn(fn->  axl_saver() end)
    receive do
      :start-> send(sender, {:ready,self()})

      {:final, sender_2}-> send(saver, {:out, sender_2})

      {index, value, k} -> send(saver, {:external, k, value})
        send(sender, {:c, index, self()})#Envío del acknoledgement

      end
    end

    defp axl_saver  do
      local=%{}
      receive do
      {:own, map} -> {:own, local=Map.merge(local, map)}
                      |>send(self())

      {:external,k,v } -> send(self(), {:own, Map.put(local, k,v)})
      {:out, sender}-> send(sender,{:s, Enum.map(local, fn {k, v} -> v end)} )
      end
    end

end
