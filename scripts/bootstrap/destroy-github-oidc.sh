#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

APP_DISPLAY_NAME="${APP_DISPLAY_NAME:-sp-cloudmart-github-training}"
CONFIRM="${CONFIRM_GITHUB_OIDC_DESTROY:-}"

[[ "$CONFIRM" == "$APP_DISPLAY_NAME" ]] || {
  echo "Refusing GitHub OIDC identity deletion." >&2
  echo "Set CONFIRM_GITHUB_OIDC_DESTROY=${APP_DISPLAY_NAME} and run again." >&2
  exit 2
}

app_id="$(
  az ad app list \
    --display-name "$APP_DISPLAY_NAME" \
    --query '[0].appId' \
    -o tsv
)"

if [[ -z "$app_id" ]]; then
  pass "GitHub OIDC Entra application already absent"
  exit 0
fi

info "Removing service principal: ${APP_DISPLAY_NAME}"

az ad sp delete \
  --id "$app_id" \
  2>/dev/null || true

info "Removing Entra application: ${APP_DISPLAY_NAME}"

az ad app delete \
  --id "$app_id"

remaining="$(
  az ad app list \
    --display-name "$APP_DISPLAY_NAME" \
    --query 'length(@)' \
    -o tsv
)"

[[ "$remaining" == "0" ]] \
  || fail "GitHub OIDC Entra application still exists"

pass "GitHub OIDC deployment identity removed"
