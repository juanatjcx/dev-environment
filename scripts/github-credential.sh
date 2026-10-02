#!/usr/bin/env bash
# Account-specific Git credential helper. Git receives the token on stdin/stdout;
# it is never written to the repository or a token file.
set -euo pipefail
account="${1:-}"
operation="${2:-}"
[[ "$operation" == get ]] || exit 0
case "$account" in juanatjcx|juanmicrosoft) ;; *) exit 1 ;; esac
protocol='' host=''
while IFS='=' read -r key value; do
  [[ -n "$key" ]] || break
  case "$key" in protocol) protocol="$value" ;; host) host="$value" ;; esac
done
[[ "$protocol" == https && "$host" == github.com ]] || exit 0
unset GH_TOKEN GITHUB_TOKEN
token="$(gh auth token --hostname github.com --user "$account")" || {
  echo "Authenticate GitHub account $account with gh auth login first." >&2
  exit 1
}
printf 'username=%s\npassword=%s\n\n' "$account" "$token"
