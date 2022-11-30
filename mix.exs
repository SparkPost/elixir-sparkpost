defmodule SparkPost.Mixfile do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :sparkpost,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      description: "The official Elixir package for the SparkPost API",
      dialyzer: dialyzer(),
      docs: [extras: ["README.md", "CONTRIBUTING.md", "CHANGELOG.md"]],
      elixir: "~> 1.10",
      package: package(),
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test],
      source_url: "https://github.com/SparkPost/elixir-sparkpost",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.6.0"
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix, :ex_unit, :poison],
      plt_core_path: "plts",
      plt_file: {:no_warn, "plts/dialyzer.plt"}
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 1.7"},
      {:poison, "~> 5.0"},
      {:mock, "~> 0.3.5", only: :test},
      {:excoveralls, "~> 0.15", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["mix.exs", "lib", "README.md", "CONTRIBUTING.md", "LICENSE.md"],
      maintainers: ["Ewan Dennis", "Nikola Begedin"],
      licenses: ["Apache 2.0"],
      links: %{
        "Github" => "https://github.com/SparkPost/elixir-sparkpost",
        "SparkPost.com" => "https://www.sparkpost.com/"
      }
    ]
  end
end
