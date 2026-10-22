#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if ! command -v claude >/dev/null; then
  echo 'Claude Code not installed; skipping plugins.'
  exit 0
fi
# Print a list file's entries without comments or blank lines; awk always ends
# each line with a newline, so a missing final newline does not drop an entry.
entries() { awk '{ sub(/#.*/, ""); sub(/[[:space:]]+$/, "") } NF' "$1"; }
failed=0
known="$(claude plugin marketplace list --json | jq -r '.[].name')"
# Read lists on fd 3 so claude keeps the terminal for any approval prompt.
while read -r name repo <&3; do
  if [[ -z "$repo" ]]; then
    echo "No repo for marketplace $name in marketplaces.txt." >&2
    failed=1
  elif ! grep -qxF "$name" <<<"$known"; then
    claude plugin marketplace add "$repo" || failed=1
  fi
done 3< <(entries "$root/claude/marketplaces.txt")
claude plugin marketplace update || failed=1
# Only user-scope installs count; project and synced plugins are separate.
installed="$(claude plugin list --json |
  jq -r '.[] | select(.scope == "user") | .id')"
# No -y: a plugin that runs its own command asks for approval in a terminal.
while read -r plugin <&3; do
  if grep -qxF "$plugin" <<<"$installed"; then
    claude plugin update "$plugin" || failed=1
  else
    claude plugin install "$plugin" || failed=1
  fi
done 3< <(entries "$root/claude/plugins.txt")
if (( failed )); then
  echo 'Some Claude Code plugins failed; see the messages above.' >&2
  exit 1
fi
echo 'Claude Code plugins are up to date; restart Claude Code to apply updates.'
