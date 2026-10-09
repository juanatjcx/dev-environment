#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
case "$(uname -s)" in
  Darwin|Linux) ;;
  *) echo 'Use WSL on Windows; see docs/windows.md.' >&2; exit 1 ;;
esac
command -v brew >/dev/null || { echo 'Install Homebrew and activate brew shellenv; see README.md.' >&2; exit 1; }
brew bundle --file="$root/Brewfile"
clone_if_missing() {
  local url="$1" dest="$2"
  if [[ ! -e "$dest" ]]; then
    git clone --depth=1 "$url" "$dest"
  fi
}
clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
bash "$root/scripts/install-shell.sh"
bash "$root/scripts/setup-node.sh"
bash "$root/scripts/setup-vim.sh"
