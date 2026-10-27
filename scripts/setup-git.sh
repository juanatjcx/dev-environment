#!/usr/bin/env bash
set -euo pipefail
if (( $# != 2 )); then
  echo 'Usage: bash scripts/setup-git.sh PERSONAL_EMAIL WORK_EMAIL' >&2
  echo 'Use an empty WORK_EMAIL to block work commits until it is configured.' >&2
  exit 2
fi
backup="$(mktemp -d "$HOME/.dev-environment-git-backup.XXXXXXXX")"
config_dir="$HOME/.config/git"
mkdir -p "$config_dir"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cp "$root/scripts/github-credential.sh" "$config_dir/github-credential.sh"
for file in "$HOME/.gitconfig" "$config_dir/juanatjcx.gitconfig" "$config_dir/juanmicrosoft.gitconfig"; do
  [[ ! -e "$file" ]] || cp -p "$file" "$backup/$(basename "$file")"
done
write_identity() {
  local account="$1" email="$2" file="$config_dir/$1.gitconfig"
  git config --file "$file" user.name 'Juan Rivera'
  git config --file "$file" user.email "$email"
  git config --file "$file" user.useConfigOnly true
  git config --file "$file" credential.https://github.com.username "$account"
  git config --file "$file" credential.https://github.com.useHttpPath true
  # Reset inherited helpers so another account cannot answer first.
  git config --file "$file" --replace-all credential.https://github.com.helper ''
  git config --file "$file" --add credential.https://github.com.helper "!bash \"$config_dir/github-credential.sh\" $account"
  git config --file "$file" dev.githubAccount "$account"
  git config --global --replace-all "includeIf.gitdir:${REPOS_HOME:-$HOME/repos}/$account/.path" "$file"
}
write_identity juanatjcx "$1"
write_identity juanmicrosoft "$2"
printf 'Git directory identities configured. Backup: %s\n' "$backup"
echo 'Commit identity is separate from authentication: see docs/accounts.md.'
