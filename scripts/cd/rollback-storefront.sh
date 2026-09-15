#!/usr/bin/env bash
# Purpose: Rolls Storefront traffic back to the previously stable revision.
# Workflow: Finds the stable revision and restores traffic without rebuilding the application images.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

az containerapp ingress traffic set \
  --resource-group "$(cloudmart_rg)" \
  --name ca-storefront-training \
  --label-weight stable=100 candidate=0 \
  --only-show-errors >/dev/null

pass "traffic rolled back to stable revision"
