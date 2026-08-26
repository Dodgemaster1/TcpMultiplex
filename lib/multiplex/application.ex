defmodule Multiplex.Application do
  use Application
  require Logger

  def start(_type, _args) do
    Multiplex.Config.load!()
    clients = Multiplex.Config.get_clients()
    Logger.debug("Loaded clients: #{inspect(clients, pretty: true)}")
    Logger.info("Server started")

    servers =
      for client <- Multiplex.Config.get_clients() do
        {ThousandIsland,
         port: client["port"],
         handler_module: Multiplex.Inbound.Handler,
         handler_options: [config: client]}
      end

    clients =
      for client <- Multiplex.Config.get_clients(),
          server <- Map.get(client, "servers", []) do
        {Multiplex.Outbound.TCPClient,
         [host: server["host"], port: server["port"], inbound_id: client["port"]]}
      end

    children = [Multiplex.Outbound.ClientRegistry]

    opts = [strategy: :one_for_one, name: Multiplex.Supervisor]
    Supervisor.start_link(children ++ servers ++ clients, opts)
  end
end
