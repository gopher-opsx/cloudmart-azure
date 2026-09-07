#!/usr/bin/env bash
set -euo pipefail

pass() { printf 'PASS %s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*" >&2; exit 1; }
info() { printf 'INFO %s\n' "$*"; }
require_cmd() { command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"; }
require_env() { [[ -n "${!1:-}" ]] || fail "required environment variable is not set: $1"; }

cloudmart_rg() { printf '%s' "${RESOURCE_GROUP:-rg-cloudmart-training-eastus}"; }

safe_az() {
  require_cmd az
  az "$@"
}

assert_eq() {
  local got="$1" want="$2" msg="$3"
  [[ "$got" == "$want" ]] || fail "$msg (expected=$want got=$got)"
  pass "$msg"
}
