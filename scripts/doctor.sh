#!/usr/bin/env bash
set -uo pipefail
missing=0
tools=(git brew zsh node npm dotnet gh aws az firebase)
# gcloud-cli is a macOS cask; Linux/WSL installs it separately when needed.
[[ "$(uname -s)" == Darwin ]] && tools+=(gcloud)
for tool in "${tools[@]}"; do
  if command -v "$tool" >/dev/null; then
    printf '%-10s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '%-10s MISSING\n' "$tool"
    missing=1
  fi
done
if command -v brew >/dev/null; then
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  brew bundle check --file="$root/Brewfile" || missing=1
fi
printf '\nOpen a new terminal and run: nvm --version; repo; gh auth status\n'
exit "$missing"
