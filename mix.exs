defmodule MulTCPlex.MixProject do
  use Mix.Project

  def project do
    [
      app: :multcplex,
      version: "0.6.3",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      tinfoil: [
        targets: [:darwin_arm64, :linux_x86_64, :windows_x86_64],
        installer: [
          enabled: true,
        ],
        github: [
          repo: "Dodgemaster1/MulTCPlex",
          draft: false,
        ],
      ],
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Multcplex.Application, []},
    ]
  end

  defp deps do
    [
      {:burrito, "~> 1.6"},
      {:tinfoil, "~> 0.2", runtime: false},
      {:thousand_island, "~> 1.0"},
      {:connection, "~> 1.1"},
      {:yaml_elixir, "~> 2.12"},
      {:optimus, "~> 0.6.1"},
      {:freedom_formatter, ">= 2.0.0", only: :dev},
    ]
  end

  def releases do
    [
      multcplex: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos_silicon: [os: :darwin, cpu: :aarch64],
            windows: [os: :windows, cpu: :x86_64],
            linux: [os: :linux, cpu: :x86_64],
          ],
        ],
      ],
    ]
  end
end
