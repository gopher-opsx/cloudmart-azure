#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
require_env STABLE_REVISION
require_env CANDIDATE_REVISION
STABLE_WEIGHT="${STABLE_WEIGHT:-90}"
CANDIDATE_WEIGHT="${CANDIDATE_WEIGHT:-10}"
[[ $((STABLE_WEIGHT + CANDIDATE_WEIGHT)) -eq 100 ]] || fail "traffic weights must add to 100"
az containerapp ingress traffic set -g "$(cloudmart_rg)" -n ca-storefront-training --revision-weight "$STABLE_REVISION=$STABLE_WEIGHT" "$CANDIDATE_REVISION=$CANDIDATE_WEIGHT"
pass "Storefront traffic set stable=$STABLE_WEIGHT candidate=$CANDIDATE_WEIGHT"
