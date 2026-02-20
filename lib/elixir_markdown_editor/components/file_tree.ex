defmodule ElixirMarkdownEditor.Components.FileTree do
  @moduledoc """
  A file tree component that renders a nested directory structure with
  expand/collapse and file selection.

  ## Usage

      <.file_tree
        id="my-tree"
        files={@files}
        selected_path={@selected_path}
        expanded_dirs={@expanded_dirs}
        on_select="select_file"
        on_toggle="toggle_dir"
      />

  ## Events

  - `on_select` - Fired when a file is clicked. Payload: `%{"path" => path}`.
  - `on_toggle` - Fired when a directory is clicked. Payload: `%{"path" => path}`.

  ## File Entry Format

  Each entry in `files` should be a map with:

      %{name: "file.ex", path: "lib/file.ex", type: :file | :directory, children: [...] | nil}
  """
  use Phoenix.Component

  alias ElixirMarkdownEditor.Language

  attr :id, :string, required: true, doc: "Unique DOM ID for the tree container."
  attr :files, :list, required: true, doc: "List of file entry maps (tree structure)."
  attr :selected_path, :string, default: nil, doc: "Currently selected file path."
  attr :expanded_dirs, :any, default: nil, doc: "MapSet of expanded directory paths."

  attr :on_select, :string,
    default: "eme:select_file",
    doc: "Event name when a file is clicked."

  attr :on_toggle, :string,
    default: "eme:toggle_dir",
    doc: "Event name when a directory is toggled."

  attr :on_create, :string, default: nil, doc: "Event name for creating a new file."
  attr :on_delete, :string, default: nil, doc: "Event name for deleting a file."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  slot :toolbar, doc: "Optional toolbar rendered above the tree."

  def file_tree(assigns) do
    assigns = assign_new(assigns, :expanded_dirs, fn -> MapSet.new() end)

    ~H"""
    <div id={@id} class={["eme-file-tree text-sm select-none", @class]}>
      <div
        :if={@toolbar != []}
        class="eme-file-tree-toolbar px-2 py-1.5 border-b border-base-300 flex items-center gap-1"
      >
        {render_slot(@toolbar)}
      </div>
      <nav class="eme-file-tree-entries py-1" role="tree" aria-label="File tree">
        <.tree_level
          entries={sort_entries(@files)}
          depth={0}
          selected_path={@selected_path}
          expanded_dirs={@expanded_dirs}
          on_select={@on_select}
          on_toggle={@on_toggle}
          on_delete={@on_delete}
        />
      </nav>
    </div>
    """
  end

  attr :entries, :list, required: true
  attr :depth, :integer, required: true
  attr :selected_path, :string
  attr :expanded_dirs, :any
  attr :on_select, :string
  attr :on_toggle, :string
  attr :on_delete, :string

  defp tree_level(assigns) do
    ~H"""
    <%= for entry <- @entries do %>
      <%= if entry.type == :directory do %>
        <.dir_entry
          entry={entry}
          depth={@depth}
          expanded={MapSet.member?(@expanded_dirs, entry.path)}
          selected_path={@selected_path}
          expanded_dirs={@expanded_dirs}
          on_select={@on_select}
          on_toggle={@on_toggle}
          on_delete={@on_delete}
        />
      <% else %>
        <.file_entry
          entry={entry}
          depth={@depth}
          selected={@selected_path == entry.path}
          on_select={@on_select}
          on_delete={@on_delete}
        />
      <% end %>
    <% end %>
    """
  end

  attr :entry, :map, required: true
  attr :depth, :integer, required: true
  attr :expanded, :boolean, required: true
  attr :selected_path, :string
  attr :expanded_dirs, :any
  attr :on_select, :string
  attr :on_toggle, :string
  attr :on_delete, :string

  defp dir_entry(assigns) do
    padding_left = (assigns.depth * 16) + 4
    assigns = assign(assigns, :padding_left, padding_left)

    ~H"""
    <div role="treeitem" aria-expanded={to_string(@expanded)}>
      <button
        type="button"
        class="eme-tree-entry group flex items-center w-full text-left py-0.5 px-1 hover:bg-base-200/70 rounded-sm transition-colors cursor-pointer"
        style={"padding-left: #{@padding_left}px"}
        phx-click={@on_toggle}
        phx-value-path={@entry.path}
        data-type="directory"
        data-path={@entry.path}
        tabindex="0"
      >
        <span class={[
          "inline-flex items-center justify-center w-4 h-4 mr-0.5 flex-shrink-0 transition-transform duration-150",
          @expanded && "rotate-90"
        ]}>
          <.chevron_icon />
        </span>
        <span class="w-4 h-4 mr-1.5 flex-shrink-0 text-amber-500 inline-flex items-center">
          <%= if @expanded do %>
            <.folder_open_icon />
          <% else %>
            <.folder_icon />
          <% end %>
        </span>
        <span class="truncate text-base-content">{@entry.name}</span>
      </button>
      <div :if={@expanded && @entry.children} role="group">
        <.tree_level
          entries={sort_entries(@entry.children)}
          depth={@depth + 1}
          selected_path={@selected_path}
          expanded_dirs={@expanded_dirs}
          on_select={@on_select}
          on_toggle={@on_toggle}
          on_delete={@on_delete}
        />
      </div>
    </div>
    """
  end

  attr :entry, :map, required: true
  attr :depth, :integer, required: true
  attr :selected, :boolean, required: true
  attr :on_select, :string
  attr :on_delete, :string

  defp file_entry(assigns) do
    padding_left = (assigns.depth * 16) + 4 + 18
    assigns = assign(assigns, :padding_left, padding_left)

    ~H"""
    <button
      type="button"
      role="treeitem"
      class={[
        "eme-tree-entry group flex items-center w-full text-left py-0.5 px-1 rounded-sm transition-colors cursor-pointer",
        if(@selected, do: "bg-primary/10 text-primary", else: "hover:bg-base-200/70 text-base-content")
      ]}
      style={"padding-left: #{@padding_left}px"}
      phx-click={@on_select}
      phx-value-path={@entry.path}
      data-type="file"
      data-path={@entry.path}
      tabindex="0"
    >
      <span class={[
        "w-4 h-4 mr-1.5 flex-shrink-0 inline-flex items-center",
        if(@selected, do: "text-primary", else: "text-base-content/50")
      ]}>
        <.file_type_icon name={@entry.name} />
      </span>
      <span class="truncate">{@entry.name}</span>
    </button>
    """
  end

  # Sort entries: directories first, then alphabetically
  defp sort_entries(entries) when is_list(entries) do
    Enum.sort_by(entries, fn entry ->
      {if(entry.type == :directory, do: 0, else: 1), String.downcase(entry.name)}
    end)
  end

  defp sort_entries(_), do: []

  # Inline SVG icons - self-contained, no dependency on consuming app's icon system

  defp chevron_icon(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3 h-3 opacity-50">
      <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
    </svg>
    """
  end

  defp folder_icon(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
      <path d="M3.75 3A1.75 1.75 0 002 4.75v3.26a3.235 3.235 0 011.75-.51h12.5c.644 0 1.245.188 1.75.51V6.75A1.75 1.75 0 0016.25 5h-4.836a.25.25 0 01-.177-.073L9.823 3.513A1.75 1.75 0 008.586 3H3.75zM3.75 9A1.75 1.75 0 002 10.75v4.5c0 .966.784 1.75 1.75 1.75h12.5A1.75 1.75 0 0018 15.25v-4.5A1.75 1.75 0 0016.25 9H3.75z" />
    </svg>
    """
  end

  defp folder_open_icon(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
      <path d="M4.75 3A1.75 1.75 0 003 4.75v2.752l.104-.002h13.792c.035 0 .07 0 .104.002V6.75A1.75 1.75 0 0015.25 5h-3.836a.25.25 0 01-.177-.073L9.823 3.513A1.75 1.75 0 008.586 3H4.75zM3.104 9a1.75 1.75 0 00-1.673 2.265l1.385 4.5A1.75 1.75 0 004.488 17h11.023a1.75 1.75 0 001.673-1.235l1.385-4.5A1.75 1.75 0 0016.896 9H3.104z" />
    </svg>
    """
  end

  attr :name, :string, required: true

  defp file_type_icon(assigns) do
    lang = Language.detect(assigns.name)
    assigns = assign(assigns, :lang, lang)

    ~H"""
    <%= case @lang do %>
      <% lang when lang in ["markdown", "plaintext"] -> %>
        <.document_text_icon />
      <% lang when lang in ["html", "xml"] -> %>
        <.code_icon />
      <% _ -> %>
        <.code_icon />
    <% end %>
    """
  end

  defp document_text_icon(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
      <path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zm2.25 8.5a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5zm0 3a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5z" clip-rule="evenodd" />
    </svg>
    """
  end

  defp code_icon(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
      <path fill-rule="evenodd" d="M6.28 5.22a.75.75 0 010 1.06L2.56 10l3.72 3.72a.75.75 0 01-1.06 1.06L.97 10.53a.75.75 0 010-1.06l4.25-4.25a.75.75 0 011.06 0zm7.44 0a.75.75 0 011.06 0l4.25 4.25a.75.75 0 010 1.06l-4.25 4.25a.75.75 0 01-1.06-1.06L17.44 10l-3.72-3.72a.75.75 0 010-1.06zM11.377 2.011a.75.75 0 01.612.867l-2.5 14.5a.75.75 0 01-1.478-.255l2.5-14.5a.75.75 0 01.866-.612z" clip-rule="evenodd" />
    </svg>
    """
  end
end
