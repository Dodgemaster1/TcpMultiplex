defmodule TcpMultiplex.MixProject do
  use Mix.Project

  def project do
    [
      app: :tcp_multiplex,
      version: "0.5.1",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      tinfoil: [
        targets: [:darwin_arm64, :linux_x86_64, :windows_x86_64],
        installer: [
          enabled: true
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Multiplex.Application, []}
    ]
  end

  defp deps do
    [
      {:burrito, "~> 1.0"},
      {:tinfoil, "~> 0.2", only: :dev, runtime: false},
      {:thousand_island, "~> 1.0"},
      {:connection, "~> 1.1"},
      {:yaml_elixir, "~> 2.12"}
    ]
  end

  def releases do
    [
      tcp_server: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos_silicon: [os: :darwin, cpu: :aarch64],
            windows: [os: :windows, cpu: :x86_64],
            linux: [os: :linux, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end
end
