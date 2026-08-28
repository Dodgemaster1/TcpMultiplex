defmodule Multcplex.Outbound.TCPClient do
  use Connection

  def child_spec(opts) do
    %{
      id:
        {__MODULE__, Keyword.fetch!(opts, :inbound_id), Keyword.fetch!(opts, :host),
         Keyword.fetch!(opts, :port)},
      start: {__MODULE__, :start_link, [opts]},
      restart: :permanent,
    }
  end

  def start_link(opts) do
    Connection.start_link(__MODULE__, opts)
  end

  def send(conn, data), do: Connection.cast(conn, {:send, data})

  def init(opts) do
    inbound_id = Keyword.fetch!(opts, :inbound_id)
    host = Keyword.fetch!(opts, :host) |> String.to_charlist()
    port = Keyword.fetch!(opts, :port)

    Multcplex.Outbound.ClientRegistry.register(inbound_id)

    s = %{host: host, port: port, sock: nil}
    {:connect, :init, s}
  end

  def connect(
        _,
        %{sock: nil, host: host, port: port} = s
      ) do
    case :gen_tcp.connect(host, port, [:binary, active: :once], 5_000) do
      {:ok, sock} ->
        {:ok, %{s | sock: sock}}

      {:error, _} ->
        {:backoff, 10_000, s}
    end
  end

  def disconnect(_info, %{sock: sock} = s) do
    if sock != nil do
      :gen_tcp.close(sock)
    end

    {:connect, :reconnect, %{s | sock: nil}}
  end

  def handle_call(_, _, %{sock: nil} = s) do
    {:reply, {:error, :closed}, s}
  end

  def handle_cast({:send, _data}, %{sock: nil} = s) do
    {:noreply, s}
  end

  def handle_cast({:send, data}, %{sock: sock} = s) do
    case :gen_tcp.send(sock, data) do
      :ok ->
        {:noreply, s}

      {:error, _} = error ->
        {:disconnect, error, s}
    end
  end

  def handle_info({:tcp, sock, _data}, %{sock: sock} = s) do
    :inet.setopts(sock, active: :once)
    {:noreply, s}
  end

  def handle_info({:tcp_closed, sock}, %{sock: sock} = s) do
    {:disconnect, {:error, :closed}, s}
  end

  def handle_info({:tcp_error, sock, reason}, %{sock: sock} = s) do
    {:disconnect, {:error, reason}, s}
  end
end
