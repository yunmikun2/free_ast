defmodule FreeAst.MixProject do
  use Mix.Project

  def project do
    [
      app: :free_ast,
      version: "0.3.2",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "FreeAst",
      source_url: "https://github.com/yunmikun2/free_ast",
      docs: [
        main: "FreeAst",
        extras: ["README.md"]
      ],

      # Hex
      description: """
      Elixir library to manage effects.
      """,
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      links: %{"GitHub" => "https://github.com/yunmikun2/free_ast"},
      licenses: ["LGPL-v3"],
      files: ~w(.formatter.exs mix.exs lib test/support README.md LICENSE.md)
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
