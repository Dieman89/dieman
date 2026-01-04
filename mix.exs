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
      {:vix, "~> 0.31"},
      {:req, "~> 0.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      build: ["dieman.build"],
      start: ["tableau.server"],
      lint: ["credo --strict"]
    ]
  end
end
