defmodule ElixirMarkdownEditor do
  @moduledoc """
  A Phoenix library providing LiveView components for file browsing and editing
  with Monaco editor.

  ## Configuration

  Configure the file store adapter in your app's config:

      config :elixir_markdown_editor, :file_store, MyApp.MyFileStoreAdapter

  The adapter must implement the `ElixirMarkdownEditor.FileStore` behaviour.

  ## Usage

  In your LiveView module:

      use ElixirMarkdownEditor.Components

  Then use the components in your templates:

      <.file_browser
        id="my-files"
        files={@files}
        scope={@scope}
        selected_path={@selected_path}
        selected_content={@selected_content}
        expanded_dirs={@expanded_dirs}
      />
  """

  @doc """
  Returns the configured file store module.

  Reads from `config :elixir_markdown_editor, :file_store`.
  """
  def file_store do
    Application.get_env(:elixir_markdown_editor, :file_store) ||
      raise """
      Missing file store configuration for :elixir_markdown_editor.

      Add to your config:

          config :elixir_markdown_editor, :file_store, MyApp.MyFileStoreAdapter
      """
  end
end
