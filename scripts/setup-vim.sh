#!/usr/bin/env bash
set -euo pipefail
# Keep editor tools on the general Node default, independent of project pins.
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  set +u
  source "$HOME/.nvm/nvm.sh"
  nvm use --silent default
  set -u
elif command -v brew >/dev/null && [[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]]; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  set +u
  source "$(brew --prefix)/opt/nvm/nvm.sh"
  nvm use --silent default
  set -u
fi
package_root="$HOME/.vim/pack/developer/start"
mkdir -p "$package_root"
for repo in prabirshrestha/vim-lsp prabirshrestha/asyncomplete.vim prabirshrestha/asyncomplete-lsp.vim mattn/vim-lsp-settings editorconfig/editorconfig-vim evanleck/vim-svelte puremourning/vimspector; do
  dest="$package_root/${repo##*/}"
  if [[ ! -e "$dest" ]]; then
    git clone --depth=1 "https://github.com/$repo.git" "$dest"
  elif [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull --ff-only --quiet || printf 'Could not update %s; left as is.\n' "$dest" >&2
  fi
done
# Isolate language-server tools from project dependencies and Node switches.
mkdir -p "$HOME/.local/share/developer-lsp"
# Latest releases, except TypeScript: 7.x no longer ships the tsserver that
# typescript-language-server needs, so stay on the newest 6.x.
npm install --prefix "$HOME/.local/share/developer-lsp" typescript@6 typescript-language-server@latest svelte-language-server@latest vscode-langservers-extracted@latest pyright@latest
mkdir -p "$HOME/.local/bin"
for tool in typescript-language-server svelteserver vscode-html-language-server vscode-css-language-server vscode-json-language-server vscode-eslint-language-server pyright-langserver; do
  target="$HOME/.local/bin/$tool"
  [[ ! -L "$target" ]] || rm "$target"
  printf '#!/bin/sh\nexport PATH="%s:$PATH"\nexec "%s" "$@"\n' "$(dirname "$(command -v node)")" "$HOME/.local/share/developer-lsp/node_modules/.bin/$tool" > "$target"
  chmod 755 "$target"
done
ln -sfn "$HOME/.local/bin/svelteserver" "$HOME/.local/bin/svelte-language-server"
if command -v dotnet >/dev/null; then
  if [[ -x "$HOME/.local/share/developer-lsp/dotnet/csharp-ls" ]]; then
    dotnet tool update csharp-ls --tool-path "$HOME/.local/share/developer-lsp/dotnet"
  else
    dotnet tool install csharp-ls --tool-path "$HOME/.local/share/developer-lsp/dotnet"
  fi
fi
if [[ -x "$HOME/.local/share/developer-lsp/dotnet/csharp-ls" ]]; then
  ln -sfn "$HOME/.local/share/developer-lsp/dotnet/csharp-ls" "$HOME/.local/bin/csharp-ls"
fi
printf 'Vim packages and web/Python language servers installed.\n'

python3 "$package_root/vimspector/install_gadget.py" --force-enable-node --update-gadget-config
# Use a debugpy wheel in an isolated Python environment instead of compiling
# Vimspector's bundled debugpy sources. Rebuild it on the newest stable
# uv-managed CPython each run.
python_version="$(uv python list --managed-python --output-format json |
  jq -r '[.[] | select(.implementation == "cpython" and .variant == "default"
    and (.version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")))][0].version')"
[[ "$python_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'No stable Python found by uv.' >&2; exit 1; }
# Build beside the current environment and swap only after debugpy imports, so a
# failed download keeps the working debugger.
debugger="$HOME/.local/share/developer-debugger"
rm -rf "$debugger.new"
uv venv --quiet --managed-python --python "$python_version" "$debugger.new"
uv pip install --python "$debugger.new/bin/python" --upgrade debugpy
"$debugger.new/bin/python" -c 'import debugpy.adapter'
rm -rf "$debugger.old"
[[ ! -e "$debugger" ]] || mv "$debugger" "$debugger.old"
mv "$debugger.new" "$debugger"
rm -rf "$debugger.old"
