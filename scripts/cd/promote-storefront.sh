#!/usr/bin/env bash
# Purpose: Promotes the verified Storefront candidate to production traffic.
# Workflow: Moves the public traffic weight to the candidate revision after the release gate has passed.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

az containerapp ingress traffic set \
  --resource-group "$(cloudmart_rg)" \
  --name ca-storefront-training \
  --label-weight stable=0 candidate=100 \
  --only-show-errors >/dev/null

pass "candidate promoted to 100%"
