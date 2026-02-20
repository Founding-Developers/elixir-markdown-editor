defmodule ElixirMarkdownEditor.Components do
  @moduledoc """
  Import all ElixirMarkdownEditor components.

  ## Usage

      use ElixirMarkdownEditor.Components

  This imports FileTree, FileEditor, and FileBrowser components into
  your LiveView or component module.
  """

  defmacro __using__(_opts) do
    quote do
      import Phoenix.Component
      import ElixirMarkdownEditor.Components.FileTree
      import ElixirMarkdownEditor.Components.FileEditor
      import ElixirMarkdownEditor.Components.FileBrowser
    end
  end
end
