defmodule Multiplex.Outbound do
  defdelegate broadcast(inbound_id, message), to: Multiplex.Outbound.ClientRegistry
end
