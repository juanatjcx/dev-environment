#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  echo 'Install Oh My Zsh with scripts/bootstrap.sh first.' >&2
  exit 1
fi
backup="$(mktemp -d "$HOME/.dev-environment-backup.XXXXXXXX")"
install_file() {
  local source="$1" target="$2" label="$3"
  if [[ -e "$target" || -L "$target" ]]; then
    cp -pP "$target" "$backup/$label"
  fi
  # Replace symlinks rather than writing through them.
  local staged
  staged="$(mktemp "${target}.XXXXXXXX")"
  cp "$source" "$staged"
  chmod 644 "$staged"
  mv -f "$staged" "$target"
}
mkdir -p "$HOME/.oh-my-zsh/custom/themes" "$HOME/.nvm"
mkdir -p "${REPOS_HOME:-$HOME/repos}/${REPOS_OWNER:-juanatjcx}" "${REPOS_HOME:-$HOME/repos}/experimental"
install_file "$root/shell/zshrc" "$HOME/.zshrc" zshrc
install_file "$root/shell/zprofile" "$HOME/.zprofile" zprofile
install_file "$root/shell/vimrc" "$HOME/.vimrc" vimrc
install_file "$root/shell/developer.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/developer.zsh-theme" developer.zsh-theme
mkdir -p "$HOME/.config/git"
install_file "$root/git/gitconfig" "$HOME/.config/git/shared.gitconfig" shared.gitconfig
install_file "$root/git/ignore" "$HOME/.config/git/ignore" git-ignore
shared="$HOME/.config/git/shared.gitconfig"
git config --global --get-all include.path | grep -qxF "$shared" ||
  git config --global --add include.path "$shared"
printf 'Shell installed. Previous files: %s\nOpen a new terminal to activate.\n' "$backup"
