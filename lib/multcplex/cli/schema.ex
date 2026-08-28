defmodule Multcplex.Cli.Schema do
  def get do
    Optimus.new!(
      name: "MulTCPlex",
      version: Application.spec(:multcplex, :vsn) |> to_string(),
      author: "Mykyta Manaiev mykyta.manaiev@gmail.com",
      allow_unknown_args: false,
      parse_double_dash: false,
      options: [
        config: [
          value_name: "CONFIG",
          help: "YAML config file",
          short: "-c",
          long: "--config",
          required: false,
          default: "config.yaml",
        ],
      ],
      subcommands: [
        update: [
          name: "update",
        ],
      ]
    )
  end
end
