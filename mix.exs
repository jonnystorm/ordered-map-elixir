defmodule OrderedMap.Mixfile do
  use Mix.Project

  def project do
    [ app: :ordered_map,
      version: "0.0.4",
      name: "OrderedMap",
      source_url: "https://github.com/jonnystorm/ordered-map-elixir",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      docs: [extras: ["README.md"]]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.13", only: :dev}]
  end
end
