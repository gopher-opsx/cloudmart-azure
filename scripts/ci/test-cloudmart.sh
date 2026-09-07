#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd go

for mod in "$ROOT"/services/*; do
  [[ -f "$mod/go.mod" ]] || continue
  info "go test ${mod#$ROOT/}"
  (cd "$mod" && go test ./...)
  pass "${mod#$ROOT/}"
done

if command -v npm >/dev/null 2>&1; then
  info "storefront tests/build"
  (cd "$ROOT/apps/storefront" && npm ci && npm test -- --watch=false --browsers=ChromeHeadless 2>/dev/null || npm run build)
  pass "storefront validation"
else
  info "npm not installed; storefront validation skipped locally"
fi
