defmodule ElixirMarkdownEditor.Language do
  @moduledoc """
  Maps file extensions to Monaco editor language identifiers.
  """

  @extension_map %{
    ".md" => "markdown",
    ".markdown" => "markdown",
    ".ex" => "elixir",
    ".exs" => "elixir",
    ".eex" => "html",
    ".heex" => "html",
    ".leex" => "html",
    ".js" => "javascript",
    ".mjs" => "javascript",
    ".jsx" => "javascript",
    ".ts" => "typescript",
    ".tsx" => "typescript",
    ".json" => "json",
    ".yaml" => "yaml",
    ".yml" => "yaml",
    ".toml" => "toml",
    ".html" => "html",
    ".htm" => "html",
    ".css" => "css",
    ".scss" => "scss",
    ".less" => "less",
    ".xml" => "xml",
    ".svg" => "xml",
    ".sql" => "sql",
    ".py" => "python",
    ".rb" => "ruby",
    ".rs" => "rust",
    ".go" => "go",
    ".java" => "java",
    ".kt" => "kotlin",
    ".swift" => "swift",
    ".c" => "c",
    ".h" => "c",
    ".cpp" => "cpp",
    ".hpp" => "cpp",
    ".cs" => "csharp",
    ".sh" => "shell",
    ".bash" => "shell",
    ".zsh" => "shell",
    ".dockerfile" => "dockerfile",
    ".graphql" => "graphql",
    ".gql" => "graphql",
    ".r" => "r",
    ".lua" => "lua",
    ".php" => "php",
    ".txt" => "plaintext",
    ".csv" => "plaintext",
    ".log" => "plaintext",
    ".env" => "plaintext",
    ".gitignore" => "plaintext"
  }

  @doc """
  Detects the Monaco language ID from a filename or path.

  Returns the language string (e.g., `"markdown"`, `"elixir"`).
  Falls back to `"plaintext"` for unknown extensions.

  ## Examples

      iex> ElixirMarkdownEditor.Language.detect("README.md")
      "markdown"

      iex> ElixirMarkdownEditor.Language.detect("lib/my_app.ex")
      "elixir"

      iex> ElixirMarkdownEditor.Language.detect("unknown.xyz")
      "plaintext"
  """
  def detect(filename) when is_binary(filename) do
    basename = Path.basename(filename)

    cond do
      String.starts_with?(basename, "Dockerfile") -> "dockerfile"
      basename == "Makefile" -> "makefile"
      basename == "Gemfile" -> "ruby"
      basename == "Rakefile" -> "ruby"
      true -> detect_by_extension(filename)
    end
  end

  defp detect_by_extension(filename) do
    ext = Path.extname(filename) |> String.downcase()
    Map.get(@extension_map, ext, "plaintext")
  end

  @doc """
  Returns the file icon name (hero icon) for a given file entry.

  ## Examples

      iex> ElixirMarkdownEditor.Language.file_icon(%{type: :directory})
      "hero-folder"

      iex> ElixirMarkdownEditor.Language.file_icon(%{type: :file, name: "app.js"})
      "hero-code-bracket"
  """
  def file_icon(%{type: :directory}), do: "hero-folder"

  def file_icon(%{type: :file, name: name}) do
    case detect(name) do
      lang when lang in ["markdown", "plaintext"] -> "hero-document-text"
      lang when lang in ["html", "xml", "svg"] -> "hero-globe-alt"
      "json" -> "hero-document-text"
      _ -> "hero-code-bracket"
    end
  end

  def file_icon(_), do: "hero-document"
end
