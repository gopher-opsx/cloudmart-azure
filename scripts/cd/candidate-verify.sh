#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_cmd curl

RG="$(cloudmart_rg)"
APP="${APP_NAME:-ca-storefront-training}"

require_env CANDIDATE_REVISION
require_env CANDIDATE_URL
require_env EXPECTED_IMAGE

health="$(
  az containerapp revision show \
    --resource-group "$RG" \
    --name "$APP" \
    --revision "$CANDIDATE_REVISION" \
    --query properties.healthState \
    -o tsv
)"
[[ "$health" == "Healthy" ]] || fail "candidate health=${health}"
pass "candidate revision healthy"

actual_image="$(
  az containerapp revision show \
    --resource-group "$RG" \
    --name "$APP" \
    --revision "$CANDIDATE_REVISION" \
    --query 'properties.template.containers[0].image' \
    -o tsv
)"
[[ "$actual_image" == "$EXPECTED_IMAGE" ]] || \
  fail "candidate image mismatch"
pass "candidate immutable image matches manifest"

curl -fsS "${CANDIDATE_URL%/}/healthz" >/dev/null || \
  fail "candidate label health endpoint"
pass "candidate direct label health"
