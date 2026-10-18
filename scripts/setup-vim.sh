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
  fi
done
# Isolate language-server tools from project dependencies and Node switches.
mkdir -p "$HOME/.local/share/developer-lsp"
npm install --prefix "$HOME/.local/share/developer-lsp" typescript@6.0.3 typescript-language-server@6.0.1 svelte-language-server@0.18.4 vscode-langservers-extracted@4.10.0 pyright@1.1.414
mkdir -p "$HOME/.local/bin"
for tool in typescript-language-server svelteserver vscode-html-language-server vscode-css-language-server vscode-json-language-server vscode-eslint-language-server pyright-langserver; do
  target="$HOME/.local/bin/$tool"
  [[ ! -L "$target" ]] || rm "$target"
  printf '#!/bin/sh\nexport PATH="%s:$PATH"\nexec "%s" "$@"\n' "$(dirname "$(command -v node)")" "$HOME/.local/share/developer-lsp/node_modules/.bin/$tool" > "$target"
  chmod 755 "$target"
done
ln -sfn "$HOME/.local/bin/svelteserver" "$HOME/.local/bin/svelte-language-server"
if command -v dotnet >/dev/null && [[ ! -x "$HOME/.local/share/developer-lsp/dotnet/csharp-ls" ]]; then
  dotnet tool install csharp-ls --tool-path "$HOME/.local/share/developer-lsp/dotnet"
fi
if [[ -x "$HOME/.local/share/developer-lsp/dotnet/csharp-ls" ]]; then
  ln -sfn "$HOME/.local/share/developer-lsp/dotnet/csharp-ls" "$HOME/.local/bin/csharp-ls"
fi
printf 'Vim packages and web/Python language servers installed.\n'

python3 "$package_root/vimspector/install_gadget.py" --force-enable-node --update-gadget-config
# Use a wheel in an isolated Python environment instead of compiling Vimspector's
# bundled debugpy sources against Homebrew's newer Python headers.
if [[ ! -x "$HOME/.local/share/developer-debugger/bin/python" ]]; then
  uv venv --python 3.13.16 "$HOME/.local/share/developer-debugger"
fi
uv pip install --python "$HOME/.local/share/developer-debugger/bin/python" debugpy==1.8.22
