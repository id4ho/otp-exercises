defmodule PingPong do
  def start do
    ponger = spawn(PingPong, :handle_message, ["ping", "pong"])
    pinger = spawn(PingPong, :handle_message, ["pong", "ping"])
    send(ponger, {pinger, "ping"})
  end

  def handle_message(receive_msg, send_msg) do
    receive do
      {pid, ^receive_msg} ->
        IO.puts "#{receive_msg}"
        Process.sleep 400
        send(pid, {self(), send_msg})
        handle_message(receive_msg, send_msg)
      _ ->
        IO.puts "idk man"
        handle_message(receive_msg, send_msg)
    end
  end
end
