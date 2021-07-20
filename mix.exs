defmodule PlugShopifyJWT.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_shopify_jwt,
      version: "0.0.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jordan Parker"],
      licenses: ["AGPL-3.0-only"],
      links: %{"GitHub" => "https://github.com/byjpr/plug_shopify_jwt"}
    ]
  end

  defp description do
    """
    A Plug to validate Shopify JWT
    """
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:versioce, "~> 1.1.1", only: :dev, runtime: false},
      {:phoenix, "~> 1.5.4"},
      {:plug_cowboy, "~> 2.0"},
      {:timex, "~> 3.7"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
