#!/usr/bin/env bash
set -uo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repos="${REPOS_HOME:-$HOME/repos}"
repos="${repos%/}"
missing=0
warnings=0
warn() { printf 'WARN  %s\n' "$*"; warnings=$((warnings + 1)); }
section() { printf '\n== %s\n' "$1"; }
# Project files under the repos tree, skipping dependency and build directories.
project_files() {
  [[ -d "$repos" ]] || return 0
  find "$repos" -maxdepth 5 \( -name node_modules -o -name .git -o -name bin \
    -o -name obj -o -name .venv -o -name venv -o -name vendor \) -prune \
    -o \( "$@" \) -print 2>/dev/null | sort
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
    dir="${nvmrc%/.nvmrc}"
    if [[ -z "$pin" ]]; then
      warn "${dir#"$repos"/} has an empty .nvmrc."
      continue
    fi
    resolved="$(nvm version "$pin")"
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
      warn "${dir#"$repos"/}: global.json does not resolve to an installed SDK."
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

  section 'Touch ID for sudo'
  if [[ -e /etc/pam.d/sudo_local && ! -r /etc/pam.d/sudo_local ]]; then
    warn 'Cannot read /etc/pam.d/sudo_local to check Touch ID for sudo.'
  elif grep -Eqs '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+([^[:space:]]*/)?pam_tid\.so' \
    /etc/pam.d/sudo_local; then
    echo 'Enabled in /etc/pam.d/sudo_local.'
  else
    warn 'Touch ID for sudo is not enabled; run scripts/setup-sudo.sh.'
  fi
fi

section Docker
docker_projects="$(project_files -name 'Dockerfile*' -o -name 'compose*.y*ml' \
  -o -name 'docker-compose*.y*ml' | while read -r file; do
    dir="$(dirname "$file")"
    [[ "$dir" == "$repos" ]] && echo . || echo "${dir#"$repos"/}"
  done | sort -u)"
if [[ -z "$docker_projects" ]]; then
  echo 'No project uses Docker; skipped.'
else
  printf 'Used by: %s\n' "$(paste -sd ' ' - <<<"$docker_projects")"
  if ! command -v docker >/dev/null; then
    warn 'docker is not on PATH.'
  else
    # macOS has no timeout(1); give docker info 10 seconds, then give up.
    docker info >/dev/null 2>&1 &
    pid=$!
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      kill -0 "$pid" 2>/dev/null || break
      sleep 1
    done
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null
      wait "$pid" 2>/dev/null
      warn 'Docker engine did not answer within 10 seconds.'
    elif wait "$pid"; then
      echo "Engine running ($(docker version --format '{{.Server.Version}}' 2>/dev/null))."
    else
      warn 'Docker engine is not running; start Docker Desktop before using it.'
    fi
  fi
fi

section 'SSH and commit signing'
if ! grep -qs '^# Installed by dev-environment' "$HOME/.ssh/config"; then
  warn 'SSH config is not the one this repo installs; run scripts/setup-ssh.sh.'
fi
agent="$(ssh -G github.com 2>/dev/null | awk '$1 == "identityagent" { $1 = ""; sub(/^ /, ""); print }')"
if [[ -z "$agent" || "$agent" == none || "$agent" == SSH_AUTH_SOCK ]]; then
  echo 'SSH uses the default agent.'
elif [[ ! -S "$agent" ]]; then
  warn 'The 1Password SSH agent is not running; turn it on in 1Password (Settings → Developer).'
else
  printf '%-14s %s key(s) in 1Password\n' 'SSH agent' "$(SSH_AUTH_SOCK="$agent" ssh-add -l 2>/dev/null | grep -c .)"
fi
for identity in "$HOME"/.config/git/*.gitconfig; do
  [[ -f "$identity" ]] || continue
  account="$(basename "$identity" .gitconfig)"
  if [[ "$(git config --file "$identity" --bool commit.gpgsign)" != true ]]; then
    printf '%-14s commits not signed\n' "$account"
  elif program="$(git config --file "$identity" gpg.ssh.program)" && [[ ! -x "$program" ]]; then
    warn "$account signs commits with $program, which is missing."
  else
    printf '%-14s commits signed\n' "$account"
  fi
done

section 'Claude Code plugins'
if ! command -v claude >/dev/null; then
  echo 'Claude Code not installed; skipped.'
elif ! command -v jq >/dev/null; then
  warn 'jq is missing, so Claude Code plugins were not checked.'
elif ! plugins="$(claude plugin list --json 2>/dev/null |
  jq -r '.[] | select(.scope == "user") | "\(.id) \(.enabled // false)"')"; then
  warn 'Could not list Claude Code plugins.'
else
  count=0
  while read -r plugin; do
    count=$((count + 1))
    if grep -qxF -e "$plugin true" <<<"$plugins"; then
      :
    elif grep -qxF -e "$plugin false" <<<"$plugins"; then
      warn "$plugin is disabled; run claude plugin enable --scope user $plugin."
    else
      warn "$plugin is not installed; run scripts/setup-claude.sh."
    fi
  done < <(awk '{ sub(/#.*/, ""); sub(/[[:space:]]+$/, "") } NF' \
    "$root/claude/plugins.txt")
  echo "Checked $count listed plugins."
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
