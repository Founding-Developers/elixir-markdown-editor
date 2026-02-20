/**
 * FileTreeHook - Keyboard navigation for the file tree.
 *
 * Enhances the server-rendered file tree with:
 * - Arrow key navigation (up/down to move focus, Enter to select/toggle)
 * - Left/Right to collapse/expand directories
 *
 * The hook communicates back to the LiveView via pushEvent.
 * All DOM rendering is handled server-side by LiveView.
 */
export const FileTreeHook = {
  mounted() {
    this.el.addEventListener("keydown", (e) => {
      const focused = document.activeElement;
      if (!focused || !focused.classList.contains("eme-tree-entry")) return;

      switch (e.key) {
        case "ArrowDown":
          e.preventDefault();
          this.focusNext(focused);
          break;
        case "ArrowUp":
          e.preventDefault();
          this.focusPrev(focused);
          break;
        case "ArrowRight":
          e.preventDefault();
          if (focused.dataset.type === "directory") {
            this.pushEvent(this.el.dataset.toggleEvent || "eme:toggle_dir", {
              path: focused.dataset.path,
            });
          }
          break;
        case "ArrowLeft":
          e.preventDefault();
          if (focused.dataset.type === "directory") {
            this.pushEvent(this.el.dataset.toggleEvent || "eme:toggle_dir", {
              path: focused.dataset.path,
            });
          }
          break;
        case "Enter":
          e.preventDefault();
          if (focused.dataset.type === "file") {
            this.pushEvent(this.el.dataset.selectEvent || "eme:select_file", {
              path: focused.dataset.path,
            });
          } else {
            this.pushEvent(this.el.dataset.toggleEvent || "eme:toggle_dir", {
              path: focused.dataset.path,
            });
          }
          break;
      }
    });
  },

  focusNext(current) {
    const entries = this.getVisibleEntries();
    const idx = entries.indexOf(current);
    if (idx >= 0 && idx < entries.length - 1) {
      entries[idx + 1].focus();
    }
  },

  focusPrev(current) {
    const entries = this.getVisibleEntries();
    const idx = entries.indexOf(current);
    if (idx > 0) {
      entries[idx - 1].focus();
    }
  },

  getVisibleEntries() {
    return Array.from(this.el.querySelectorAll(".eme-tree-entry"));
  },
};
