defmodule GeneratePackage do

  def new(n) do
    Enum.map(1..n, fn x -> num = :rand.uniform(2)-1 end)
  end
  
end

defmodule SlidingWindow do

  def new(n) do
    package = GeneratePackage.new(n)
    k = :rand.uniform(div(n, 2))
    #sender = spawn(fn -> sender_loop(package, n, k) end)
    #recvr = spawn(fn -> recvr_loop(sender) end)
  end



  
  def sender_loop(package, n, k) do
    axl_sender(package, 0, n ,k)
  end

  def axl_sender(package, i, n, k) do
    if i>=n do
      package
    end
    send(recv_loop, {i, Enum.at(package, i)})

    receive do
      {w,v} -> if w==i do
                axl_sender(package,i+1,n,k)
               end
    end

  end

  def recvr_loop(sender) do
    out=[]
    m={:a, 2}
    receive do
      {x , y} -> out++[y]
      send(axl_sender, {x,y})
      after 
        5000 -> :timeout 
    end
  end
  
end
