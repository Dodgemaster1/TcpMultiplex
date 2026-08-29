defmodule Multcplex.Application do
  use Application
  require Logger

  def start(_type, _args) do
    args = if Burrito.Util.running_standalone?() do
      Burrito.Util.Args.argv()
    else
      System.argv()
    end
    Multcplex.Cli.Handler.process(args)
    clients = Multcplex.Config.get_clients()
    Logger.debug("Loaded clients: #{inspect(clients, pretty: true)}")

    servers =
      for client <- Multcplex.Config.get_clients() do
        {ThousandIsland,
         port: client["port"],
         handler_module: Multcplex.Inbound.Handler,
         handler_options: [config: client]}
      end

    clients =
      for client <- Multcplex.Config.get_clients(),
          server <- Map.get(client, "servers", []) do
        {Multcplex.Outbound.TCPClient,
         [host: server["host"], port: server["port"], inbound_id: client["port"]]}
      end

    children = [Multcplex.Outbound.ClientRegistry]

    opts = [strategy: :one_for_one, name: Multcplex.Supervisor]
    result = Supervisor.start_link(children ++ servers ++ clients, opts)
    Logger.info("Server started (#{result})")
    result
  end
end
