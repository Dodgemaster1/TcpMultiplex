defmodule Multcplex.Outbound.ClientRegistry do
  @default_name __MODULE__

  def child_spec(opts) do
    name = Keyword.get(opts, :name, @default_name)

    %{
      id: name,
      start: {__MODULE__, :start_link, [opts]},
    }
  end

  def start_link(opts) do
    name = Keyword.get(opts, :name, @default_name)
    Registry.start_link(keys: :duplicate, name: name)
  end

  def register(inbound_id, metadata \\ %{}, registry_name \\ @default_name) do
    Registry.register(registry_name, inbound_id, metadata)
  end

  def broadcast(inbound_id, message, registry_name \\ @default_name) do
    registry_name
    |> Registry.lookup(inbound_id)
    |> Enum.each(fn {pid, _metadata} -> Multcplex.Outbound.TCPClient.send(pid, message) end)
  end

  def get_all(registry_name \\ @default_name) do
    match_spec = [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}]
    Registry.select(registry_name, match_spec)
  end
end
