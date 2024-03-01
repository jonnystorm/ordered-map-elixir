defmodule OrderedMap.Mixfile do
  use Mix.Project

  @version "0.0.7"
  @source_url "https://gitlab.com/jonnystorm/ordered-map-elixir"

  def project do
    [
      app: :ordered_map,
      version: @version,
      name: "OrderedMap",
      description: "An order-preserving map implementation for Elixir.",
      source_url: @source_url,
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      aliases: aliases(),
      docs: docs(),
      dialyzer: [
        add_plt_apps: [
          :logger,
          :ordered_map
        ],
        ignore_warnings: "dialyzer.ignore",
        flags: [
          :unmatched_returns,
          :error_handling,
          :race_conditions,
          :underspecs
        ]
      ]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.23", only: :dev}]
  end

  defp package do
    [
      licenses: ["MPL-2.0"],
      links: %{GitLab: @source_url}
    ]
  end

  defp aliases do
    [publish: ["hex.publish", "tag"], tag: &tag_release/1]
  end

  defp tag_release(_) do
    Mix.shell().info("Tagging release as #{@version}")
    System.cmd("git", ["tag", @version])
    System.cmd("git", ["push", "--tags"])
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: @version,
      extras: ["README.md"]
    ]
  end
end
