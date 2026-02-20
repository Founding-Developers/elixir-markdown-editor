defmodule ElixirMarkdownEditor.Components.FileEditor do
  @moduledoc """
  A Monaco editor wrapper component with automatic language detection and a header bar.

  Builds on top of `LiveMonacoEditor.code_editor/1`.

  ## Usage

      <.file_editor
        id="my-editor"
        path="lib/my_file.ex"
        value={@file_content}
        on_change="file_changed"
        on_save="file_saved"
      />

  ## Events

  - `on_change` - Fired when the editor content changes. Payload: `%{"value" => content}`.
  - `on_save` - Fired when the save button is clicked. Payload: `%{"path" => path}`.
  """
  use Phoenix.Component

  alias ElixirMarkdownEditor.Language

  @doc """
  The fixed Monaco model path used internally.
  LiveMonacoEditor uses `phx-update="ignore"`, so the editor DOM is never
  patched after mount. We use a fixed path so `set_value/3` and
  `change_language/3` always target the same event listener.
  """
  @editor_model_path "eme-editor"

  def editor_model_path, do: @editor_model_path

  attr :id, :string, required: true, doc: "Unique DOM ID for the editor container."

  attr :path, :string,
    required: true,
    doc: "File path being edited. Used for language detection and as the Monaco model path."

  attr :value, :string, default: "", doc: "Current file content."

  attr :on_change, :string,
    default: "eme:file_changed",
    doc: "Event name when content changes. Receives `%{\"value\" => content}`."

  attr :on_save, :string,
    default: nil,
    doc: "Event name for the save button. Receives `%{\"path\" => path}`. Hidden when nil."

  attr :show_header, :boolean, default: true, doc: "Whether to show the filename header bar."

  attr :language, :string,
    default: nil,
    doc: "Override auto-detected language. Nil means auto-detect from path."

  attr :opts, :map, default: %{}, doc: "Additional Monaco editor options merged with defaults."
  attr :class, :string, default: nil, doc: "Additional CSS classes on the root container."

  attr :style, :string,
    default: "width: 100%; height: 100%;",
    doc: "Inline style for the Monaco editor."

  attr :read_only, :boolean, default: false, doc: "Whether the editor is read-only."
  attr :dirty, :boolean, default: false, doc: "Whether the file has unsaved changes."

  def file_editor(assigns) do
    detected_language = assigns.language || Language.detect(assigns.path)
    filename = Path.basename(assigns.path)

    editor_opts =
      Map.merge(
        LiveMonacoEditor.default_opts(),
        %{
          "language" => detected_language,
          "theme" => "vs",
          "wordWrap" => "on",
          "fontSize" => 14,
          "minimap" => %{"enabled" => false},
          "scrollBeyondLastLine" => false,
          "automaticLayout" => true,
          "readOnly" => assigns.read_only
        }
      )
      |> Map.merge(assigns.opts)

    assigns =
      assigns
      |> assign(:detected_language, detected_language)
      |> assign(:filename, filename)
      |> assign(:editor_opts, editor_opts)
      |> assign(:editor_model_path, @editor_model_path)

    ~H"""
    <div id={@id} class={["eme-file-editor flex flex-col min-h-0 h-full", @class]}>
      <div
        :if={@show_header}
        class="eme-file-editor-header flex items-center justify-between px-3 py-2 border-b border-base-300 bg-base-200/50 text-sm flex-shrink-0"
      >
        <div class="flex items-center gap-2 min-w-0">
          <span class="font-mono text-base-content truncate">{@filename}</span>
          <span class="text-xs text-base-content/50 flex-shrink-0">{@detected_language}</span>
        </div>
        <div class="flex items-center gap-2 flex-shrink-0">
          <span
            :if={@dirty}
            class="text-xs text-amber-600 bg-amber-50 px-2 py-0.5 rounded font-medium"
          >
            Unsaved
          </span>
          <button
            :if={@on_save}
            phx-click={@on_save}
            phx-value-path={@path}
            disabled={!@dirty}
            class={[
              "text-xs px-3 py-1 rounded-md transition-all flex-shrink-0",
              if(@dirty,
                do: "bg-blue-600 text-white hover:bg-blue-700",
                else: "bg-base-300/50 text-base-content/30 cursor-not-allowed"
              )
            ]}
          >
            Save
          </button>
        </div>
      </div>
      <div class="flex-1 min-h-0 overflow-hidden">
        <LiveMonacoEditor.code_editor
          path={@editor_model_path}
          value={@value}
          style={@style}
          opts={@editor_opts}
          change={@on_change}
        />
      </div>
    </div>
    """
  end

  @doc """
  Changes the editor value programmatically via push_event.
  Delegates to `LiveMonacoEditor.set_value/3`.
  """
  defdelegate set_value(socket, value, opts \\ []), to: LiveMonacoEditor

  @doc """
  Changes the editor language programmatically via push_event.
  Delegates to `LiveMonacoEditor.change_language/3`.
  """
  defdelegate change_language(socket, language, opts \\ []), to: LiveMonacoEditor
end
