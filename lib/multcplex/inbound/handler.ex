defmodule Multcplex.Inbound.Handler do
  use ThousandIsland.Handler
  alias ThousandIsland.Socket
  alias Multcplex.Outbound

  @impl ThousandIsland.Handler
  def handle_connection(socket, state) do
    allowed_ips = state[:config]["allowed_ips"]

    case Socket.peername(socket) do
      {:ok, {addr, _port}} ->
        if is_nil(allowed_ips) or addr in allowed_ips do
          {:continue, state, state[:config]["timeout"]}
        else
          {:error, :wrong_ip, state}
        end

      _ ->
        {:error, :wrong_ip, state}
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    Outbound.broadcast(state[:config]["port"], data)
    Socket.send(socket, "ok")
    {:continue, state, state[:config]["timeout"]}
  end
end
