#!/usr/bin/env bash
# Purpose: Applies explicit traffic weights to Storefront revisions in Azure Container Apps.
# Workflow: Provides the reusable Azure CLI operation used by candidate, promotion, and rollback workflows.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

STABLE_WEIGHT="${STABLE_WEIGHT:-90}"
CANDIDATE_WEIGHT="${CANDIDATE_WEIGHT:-10}"

[[ $((STABLE_WEIGHT + CANDIDATE_WEIGHT)) -eq 100 ]] || \
  fail "traffic weights must add to 100"

az containerapp ingress traffic set \
  --resource-group "$(cloudmart_rg)" \
  --name ca-storefront-training \
  --label-weight \
    "stable=${STABLE_WEIGHT}" \
    "candidate=${CANDIDATE_WEIGHT}" \
  --only-show-errors >/dev/null

pass "Storefront traffic stable=${STABLE_WEIGHT}% candidate=${CANDIDATE_WEIGHT}%"
