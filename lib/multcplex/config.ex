defmodule Multcplex.Config do
  @key {__MODULE__, :config}

  def load(path \\ "config.yaml") do
    with {:ok, config} <- parse_yaml(path),
         :ok <- validate_ports(config) do
      config =
        update_in(
          config,
          [Access.key("clients", []), Access.all(), Access.key("timeout", 300)],
          &(&1 * 1000)
        )

      :persistent_term.put(@key, config)
      :ok
    end
  end

  defp parse_yaml(path) do
    case YamlElixir.read_from_file(path) do
      {:ok, config} ->
        {:ok, config}

      {:error, %YamlElixir.ParsingError{message: message}} ->
        {:error, "Error in YAML syntax #{path}: #{message}"}

      {:error, :enoent} ->
        {:error, "Config not found: #{path}"}

      {:error, reason} ->
        {:error, "Cannot read the file #{path}: #{inspect(reason)}"}
    end
  end

  defp validate_ports(config) do
    if ports_unique?(config) do
      :ok
    else
      {:error, "Ports aren't unique"}
    end
  end

  defp ports_unique?(config) do
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
