defmodule Multiplex.Config do
  @key {__MODULE__, :config}

  def load!(path \\ "config.yaml") do
    config = YamlElixir.read_from_file!(path)
    if not ports_unique?(config), do: raise("Ports aren't unique")

    config =
      update_in(
        config,
        [Access.key("clients", []), Access.all(), Access.key("timeout", 30)],
        &(&1 * 1000)
      )

    :persistent_term.put(@key, config)
    :ok
  end

  def ports_unique?(config) do
    clients = config["clients"] || []
    ports = Enum.map(clients, & &1["port"])

    length(ports) == length(Enum.uniq(ports))
  end

  def fetch() do
    :persistent_term.get(@key)
  end

  def get_clients() do
    fetch()
    |> Map.get("clients", [])
  end
end
