defmodule ElixirMarkdownEditor.Components.FileBrowser do
  @moduledoc """
  Integrated file browser combining a file tree and Monaco editor in a
  side-by-side layout.

  This is the primary "batteries included" component. It renders a file tree
  on the left and a Monaco editor on the right. File selection, content loading,
  and saving are handled by the consuming LiveView through events.

  ## Usage

      <.file_browser
        id="agent-files"
        files={@files}
        scope={@scope}
        selected_path={@selected_path}
        selected_content={@selected_content}
        expanded_dirs={@expanded_dirs}
      />

  ## Events the consuming LiveView must handle

  - `eme:select_file` - A file was clicked. Call `FileStore.read_file/2` and update assigns.
  - `eme:toggle_dir` - A directory was clicked. Toggle the path in `expanded_dirs` MapSet.
  - `eme:file_changed` - Editor content was modified. Update `selected_content` assign.
  - `eme:file_saved` - Save button clicked. Call `FileStore.write_file/3`.
  """
  use Phoenix.Component

  alias ElixirMarkdownEditor.Components.FileTree
  alias ElixirMarkdownEditor.Components.FileEditor

  attr :id, :string, required: true, doc: "Unique DOM ID."
  attr :files, :list, required: true, doc: "File tree data from FileStore.list_files/1."
  attr :scope, :any, required: true, doc: "Opaque scope passed through for context."
  attr :selected_path, :string, default: nil, doc: "Currently selected file path."
  attr :selected_content, :string, default: "", doc: "Content of the selected file."
  attr :expanded_dirs, :any, default: nil, doc: "MapSet of expanded directory paths."

  attr :on_change, :string,
    default: "eme:file_changed",
    doc: "Event name when file content changes."

  attr :on_save, :string, default: "eme:file_saved", doc: "Event name when save is requested."

  attr :on_select, :string,
    default: "eme:select_file",
    doc: "Event name when a file is selected."

  attr :on_toggle, :string,
    default: "eme:toggle_dir",
    doc: "Event name when a directory is toggled."

  attr :on_create, :string, default: nil, doc: "Event name for new file creation."
  attr :on_delete, :string, default: nil, doc: "Event name for file deletion."
  attr :tree_width, :string, default: "w-64", doc: "Width class for the file tree panel."
  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :editor_opts, :map, default: %{}, doc: "Additional Monaco editor options."
  attr :read_only, :boolean, default: false, doc: "Whether editing is disabled."
  attr :dirty, :boolean, default: false, doc: "Whether the current file has unsaved changes."

  slot :tree_toolbar, doc: "Content rendered above the file tree (action buttons, etc.)."
  slot :empty_state, doc: "Content shown when no file is selected."

  def file_browser(assigns) do
    assigns = assign_new(assigns, :expanded_dirs, fn -> MapSet.new() end)

    ~H"""
    <div
      id={@id}
      class={[
        "eme-file-browser flex min-h-0 border border-base-300 rounded-lg overflow-hidden bg-base-100",
        @class
      ]}
    >
      <%!-- File Tree Panel --%>
      <div class={[
        "eme-file-browser-tree border-r border-base-300 bg-base-200/30 flex-shrink-0 overflow-y-auto",
        @tree_width
      ]}>
        <FileTree.file_tree
          id={"#{@id}-tree"}
          files={@files}
          selected_path={@selected_path}
          expanded_dirs={@expanded_dirs}
          on_select={@on_select}
          on_toggle={@on_toggle}
          on_create={@on_create}
          on_delete={@on_delete}
        >
          <:toolbar>
            {render_slot(@tree_toolbar)}
          </:toolbar>
        </FileTree.file_tree>
      </div>

      <%!-- Editor Panel --%>
      <div class="eme-file-browser-editor flex-1 flex flex-col min-h-0 min-w-0">
        <%= if @selected_path do %>
          <FileEditor.file_editor
            id={"#{@id}-editor"}
            path={@selected_path}
            value={@selected_content}
            on_change={@on_change}
            on_save={@on_save}
            opts={@editor_opts}
            read_only={@read_only}
            dirty={@dirty}
          />
        <% else %>
          <div class="flex-1 flex items-center justify-center text-base-content/50">
            <%= if @empty_state != [] do %>
              {render_slot(@empty_state)}
            <% else %>
              <div class="text-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 mx-auto mb-3 opacity-30" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zm2.25 8.5a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5zm0 3a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5z" clip-rule="evenodd" />
                </svg>
                <p class="text-base font-medium">No file selected</p>
                <p class="text-sm mt-1 opacity-70">Select a file from the tree to begin editing</p>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
