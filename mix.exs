defmodule SparkPost.Mixfile do
  use Mix.Project

  def project do
    [app: :sparkpost,
     version: "0.5.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/SparkPost/elixir-sparkpost",
     description: "The official Elixir package for the SparkPost API",
     package: package(),
     deps: deps(),
     docs: [
       extras: ["README.md", "CONTRIBUTING.md", "CHANGELOG.md"]
     ],
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test]
   ]
  end

  def application do
    [applications: [:httpoison]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9"},
      {:poison, "~> 3.0"},
      {:mock, "~> 0.2.0", only: :test},
      {:excoveralls, "~> 0.5.7", only: :test},
      {:credo, "~> 0.5.1", only: [:dev, :test]},
      {:earmark, "~> 1.0.3", only: :dev},
      {:ex_doc, "~> 0.14.3", only: :dev}
    ]
  end

  defp package do
    [
      files: ["mix.exs", "lib", "README.md", "CONTRIBUTING.md", "LICENSE.md"],
      maintainers: ["Ewan Dennis", "Rich Leland"],
      licenses: ["Apache 2.0"],
      links: %{
        "Github" => "https://github.com/SparkPost/elixir-sparkpost",
        "SparkPost.com" => "https://www.sparkpost.com/"
      }
    ]
  end
end

