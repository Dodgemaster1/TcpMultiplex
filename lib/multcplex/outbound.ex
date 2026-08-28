defmodule Multcplex.Outbound do
  defdelegate broadcast(inbound_id, message), to: Multcplex.Outbound.ClientRegistry
end
