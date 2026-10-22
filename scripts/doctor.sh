#!/usr/bin/env bash
set -uo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repos="${REPOS_HOME:-$HOME/repos}"
missing=0
warnings=0
warn() { printf 'WARN  %s\n' "$*"; warnings=$((warnings + 1)); }
section() { printf '\n== %s\n' "$1"; }
# Project files under the repos tree, skipping dependency and build directories.
project_files() {
  [[ -d "$repos" ]] || return 0
  find "$repos" -maxdepth 5 \( -name node_modules -o -name .git -o -name bin \
    -o -name obj \) -prune -o \( "$@" \) -print 2>/dev/null | sort
}

section Tools
tools=(git brew zsh node npm dotnet gh aws az firebase jq uv)
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
  brew bundle check --file="$root/Brewfile" || missing=1
fi

section 'Node (nvm)'
nvm_script="${NVM_DIR:-$HOME/.nvm}/nvm.sh"
[[ -s "$nvm_script" ]] || nvm_script="$(brew --prefix 2>/dev/null)/opt/nvm/nvm.sh"
if [[ -s "$nvm_script" ]]; then
  # nvm is not guaranteed to support nounset in every release.
  set +u
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  source "$nvm_script"
  printf 'default    %s\n' "$(nvm version default)"
  while read -r nvmrc; do
    pin="$(tr -d '[:space:]' <"$nvmrc")"
    resolved="$(nvm version "$pin")"
    dir="${nvmrc%/.nvmrc}"
    if [[ "$resolved" == N/A ]]; then
      warn "${dir#"$repos"/} pins Node $pin, which is not installed; run nvm install there."
    else
      printf '%-10s %s (%s)\n' "$resolved" "${dir#"$repos"/}" "$pin"
    fi
  done < <(project_files -name .nvmrc)
  set -u
else
  warn 'nvm not found; run scripts/setup-node.sh.'
fi

section '.NET SDK'
if command -v dotnet >/dev/null; then
  printf 'default    %s\n' "$(dotnet --version)"
  while read -r global_json; do
    dir="${global_json%/global.json}"
    if sdk="$(cd "$dir" && dotnet --version 2>/dev/null)"; then
      printf '%-10s %s\n' "$sdk" "${dir#"$repos"/}"
    else
      warn "${dir#"$repos"/} has no installed SDK matching its global.json."
    fi
  done < <(project_files -name global.json)
fi

if [[ "$(uname -s)" == Darwin ]]; then
  section Xcode
  developer_dir="$(xcode-select -p 2>/dev/null)"
  case "$developer_dir" in
    */Xcode*.app/*) printf '%s (%s)\n' "$developer_dir" \
      "$(xcodebuild -version 2>/dev/null | head -n 1)" ;;
    "") warn 'No developer tools selected; see docs/recovery.md.' ;;
    *) warn "Command Line Tools selected ($developer_dir); select Xcode for Apple builds." ;;
  esac
fi

section Docker
docker_projects="$(project_files -name 'Dockerfile*' -o -name 'compose*.y*ml' \
  -o -name 'docker-compose*.y*ml' | sed "s|^$repos/||; s|/[^/]*$||" | sort -u)"
if [[ -z "$docker_projects" ]]; then
  echo 'No project uses Docker; skipped.'
else
  printf 'Used by: %s\n' "$(paste -sd ' ' - <<<"$docker_projects")"
  if ! command -v docker >/dev/null; then
    warn 'docker is not on PATH.'
  elif docker info >/dev/null 2>&1; then
    echo "Engine running ($(docker version --format '{{.Server.Version}}' 2>/dev/null))."
  else
    warn 'Docker engine is not running; start Docker Desktop before using it.'
  fi
fi

section 'Claude Code plugins'
if command -v claude >/dev/null && command -v jq >/dev/null; then
  installed="$(claude plugin list --json 2>/dev/null |
    jq -r '.[] | select(.scope == "user" and .enabled) | .id')"
  count=0
  while read -r plugin; do
    count=$((count + 1))
    grep -qxF "$plugin" <<<"$installed" ||
      warn "$plugin is not installed and enabled; run scripts/setup-claude.sh."
  done < <(awk '{ sub(/#.*/, ""); sub(/[[:space:]]+$/, "") } NF' "$root/claude/plugins.txt")
  echo "Checked $count listed plugins."
else
  echo 'Claude Code not installed; skipped.'
fi

section Summary
if (( missing )); then
  echo 'Missing tools or Brewfile entries; run scripts/bootstrap.sh.'
else
  echo 'All tools present.'
fi
echo "$warnings warning(s)."
printf '\nOpen a new terminal and run: nvm --version; repo; gh auth status\n'
exit "$missing"
