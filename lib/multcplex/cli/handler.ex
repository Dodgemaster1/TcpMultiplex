defmodule Multcplex.Cli.Handler do
  def process(args) do
    args = Multcplex.Cli.Schema.get() |> Optimus.parse!(args)
    dbg(args)

    case args do
      {[:update], _} ->
        case update_app(:os.type()) do
          :ok -> System.halt(0)
          {:error, code} -> System.halt(code)
        end

      _ ->
        :ok
    end

    with {:error, message} <- Multcplex.Config.load(args.options.config) do
      IO.puts(:stderr, message)
      System.halt(1)
    end
  end

  @sh_url "https://raw.githubusercontent.com/Dodgemaster1/MulTCPlex/main/scripts/install.sh"
  @ps_url "https://raw.githubusercontent.com/Dodgemaster1/MulTCPlex/main/scripts/install.ps1"

  def update_app({:win32, _}) do
    ps_cmd = "irm #{@ps_url} | iex"

    case System.cmd(
           "powershell",
           ["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps_cmd],
           into: IO.stream(:stdio, :line)
         ) do
      {_, 0} ->
        :ok

      {_, code} ->
        IO.puts("\nerror: Installation script failed with exit code #{code}")
        {:error, code}
    end
  end

  def update_app({:unix, _}) do
    cmd = "curl -fsSL #{@sh_url} | sh"

    case System.cmd("sh", ["-c", cmd], into: IO.stream(:stdio, :line)) do
      {_, 0} ->
        :ok

      {_, code} ->
        IO.puts("\nerror: Installation script failed with exit code #{code}")
        {:error, code}
    end
  end
end
