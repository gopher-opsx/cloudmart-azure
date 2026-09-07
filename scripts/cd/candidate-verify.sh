#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
require_cmd curl
RG="$(cloudmart_rg)"
APP="${APP_NAME:-ca-storefront-training}"
require_env CANDIDATE_REVISION
health="$(az containerapp revision show -g "$RG" -n "$APP" --revision "$CANDIDATE_REVISION" --query properties.healthState -o tsv)"
[[ "$health" == "Healthy" ]] || fail "candidate health=$health"
pass "candidate revision healthy"
# When revision labels are enabled, pass CANDIDATE_URL for direct pre-promotion testing.
if [[ -n "${CANDIDATE_URL:-}" ]]; then
  curl -fsS "${CANDIDATE_URL%/}/healthz" >/dev/null || fail "candidate direct health"
  pass "candidate direct health"
else
  info "CANDIDATE_URL not set; direct candidate request skipped"
fi
