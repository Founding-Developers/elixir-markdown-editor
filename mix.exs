defmodule ElixirMarkdownEditor.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/Founding-Developers/elixir-markdown-editor"

  def project do
    [
      app: :elixir_markdown_editor,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ElixirMarkdownEditor",
      description: "Phoenix LiveView components for file browsing and editing with Monaco editor",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 0.20 or ~> 1.0"},
      {:phoenix_html, "~> 4.0"},
      {:live_monaco_editor, "~> 0.2"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Founding Developers"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib assets mix.exs README.md LICENSE .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end
end
