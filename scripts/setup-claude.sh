#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if ! command -v claude >/dev/null; then
  echo 'Claude Code not installed; skipping plugins.'
  exit 0
fi
# Lines are "<value>" with optional comments; print the meaningful ones.
entries() { sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$1"; }
known="$(claude plugin marketplace list --json | jq -r '.[].name')"
# Read lists on fd 3 so claude keeps the terminal for any approval prompt.
while read -r name repo <&3; do
  grep -qxF "$name" <<<"$known" || claude plugin marketplace add "$repo"
done 3< <(entries "$root/claude/marketplaces.txt")
claude plugin marketplace update
installed="$(claude plugin list --json | jq -r '.[].id')"
# No -y: a plugin that runs its own command still asks for approval.
while read -r plugin <&3; do
  if grep -qxF "$plugin" <<<"$installed"; then
    claude plugin update "$plugin"
  else
    claude plugin install "$plugin"
  fi
done 3< <(entries "$root/claude/plugins.txt")
echo 'Claude Code plugins are installed; restart Claude Code to apply updates.'
