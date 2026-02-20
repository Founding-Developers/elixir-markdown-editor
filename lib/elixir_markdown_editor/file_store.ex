defmodule ElixirMarkdownEditor.FileStore do
  @moduledoc """
  Behaviour for file storage backends.

  Implement this behaviour to provide file access for the editor components.
  The `scope` parameter is an opaque term defined by the consuming application
  (e.g., an org_id + agent_slug map, an S3 bucket prefix, a database record ID).

  ## File Entry Structure

  `list_files/1` must return a list of file entries with the following shape:

      %{
        name: "README.md",
        path: "README.md",
        type: :file,           # :file or :directory
        children: nil           # list of file entries for directories, nil for files
      }

  ## Example Implementation

      defmodule MyApp.LocalFileStore do
        @behaviour ElixirMarkdownEditor.FileStore

        @impl true
        def list_files(%{root: root}) do
          {:ok, build_tree(root, "")}
        end

        @impl true
        def read_file(%{root: root}, path) do
          File.read(Path.join(root, path))
        end

        # ... etc
      end
  """

  @type scope :: term()
  @type path :: String.t()
  @type file_entry :: %{
          name: String.t(),
          path: String.t(),
          type: :file | :directory,
          children: [file_entry()] | nil
        }

  @doc "List files and directories for the given scope, returning a tree structure."
  @callback list_files(scope()) :: {:ok, [file_entry()]} | {:error, term()}

  @doc "Read the content of a file."
  @callback read_file(scope(), path()) :: {:ok, String.t()} | {:error, term()}

  @doc "Write content to a file (create or overwrite)."
  @callback write_file(scope(), path(), content :: String.t()) :: :ok | {:error, term()}

  @doc "Create a new empty file."
  @callback create_file(scope(), path()) :: :ok | {:error, term()}

  @doc "Delete a file."
  @callback delete_file(scope(), path()) :: :ok | {:error, term()}

  @doc "Rename or move a file."
  @callback rename_file(scope(), old_path :: path(), new_path :: path()) :: :ok | {:error, term()}
end
