defmodule Dieman.MixProject do
  use Mix.Project

  def project do
    [
      app: :dieman,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tableau, "~> 0.28"},
      {:temple, "~> 0.14.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      build: ["tableau.build"],
      start: ["tableau.server"],
      lint: ["credo --strict"]
    ]
  end
end
