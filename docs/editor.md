# Vim language tooling

Run `bash scripts/setup-vim.sh`, then `bash scripts/install-shell.sh`.
Bootstrap runs both. Native packages live under `~/.vim/pack/developer/start`:
vim-lsp, vim-lsp-settings, asyncomplete.vim, asyncomplete-lsp.vim, and
editorconfig-vim, vim-svelte, and Vimspector. Missing packages are cloned; existing checkouts are retained.
Update those Git checkouts deliberately when needed.

Web and Python language servers are installed in
`~/.local/share/developer-lsp` and linked into `~/.local/bin`, independently of
project npm dependencies. Server wrappers use the Node default selected at
installation, so older project runtimes do not break editor tooling. Web server
versions are pinned in `setup-vim.sh`; review compatibility before upgrading. This covers TypeScript/JavaScript, Svelte, HTML,
CSS, JSON, ESLint, and Python. C# uses csharp-ls installed as an isolated
.NET tool when dotnet is available. Open Vim from a new shell for the updated PATH.
For additional languages use `:LspInstallServer`; server availability and
runtime requirements vary. No project dependencies are installed by Vim.

- Completion appears as you type; Ctrl-N/Ctrl-P select candidates.
- `gd`: definition; `gr`: references; `K`: hover documentation.
- `[g` / `]g`: previous/next diagnostic.
- Space then `rn`: rename; Space then `ca`: code action.
- Space then `f`: request server formatting. Formatting is explicit, not on save;
  project formatter configuration remains authoritative.
- `.editorconfig` controls indentation and whitespace.

Personal overrides belong in `~/.vimrc.local`. Vimspector installs Node and Python adapters. Project launch
configurations belong in `.vimspector.json`.

The current Svelte server depends on Svelte 4. npm audit flags moderate Svelte
advisories in this isolated editor tool installation and reports no automatic
fix. These dependencies are not added to any project's application bundle.

## Debugging

Homebrew Vim provides the Python support required by Vimspector. F5 starts or
continues debugging; F9 toggles a breakpoint; F10 steps over and F11 steps in.
Use `:call vimspector#Reset()` to close a debug session.

The installed adapters are `debugpy` (Python) and `js-debug` (Node).
The Python adapter runs in an isolated uv environment using Python 3.13;
project Python runtimes can be chosen separately in the launch configuration. Create a
project `.vimspector.json` with the entry point and runtime it actually uses.
For example, a Node script can use:

```json
{
  "configurations": {
    "Node script": {
      "adapter": "js-debug",
      "configuration": {
        "request": "launch",
        "type": "pwa-node",
        "program": "${file}",
        "cwd": "${workspaceRoot}"
      }
    }
  }
}
```

C# completion uses csharp-ls; a C# debugger adapter is not installed because
platform support must be verified for macOS ARM64. Azure Functions and browser
apps need their own attach/launch configuration rather than the script example.
Reference: https://github.com/puremourning/vimspector
