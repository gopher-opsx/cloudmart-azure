#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_cmd curl

RG="$(cloudmart_rg)"

info "platform foundation"
"$ROOT/scripts/verify-platform-foundation.sh"

info "Container App revisions"
"$ROOT/scripts/cd/verify-release.sh"

info "backend runtime and internal discovery"
"$ROOT/scripts/container-apps/verify-backend-runtime.sh"

info "security baseline"
"$ROOT/scripts/security/verify-security-baseline.sh"

storefront_fqdn="$(
  az containerapp show \
    --resource-group "$RG" \
    --name ca-storefront-training \
    --query properties.configuration.ingress.fqdn \
    -o tsv
)"
[[ -n "$storefront_fqdn" ]] || fail "Storefront public FQDN missing"

export STOREFRONT_URL="https://${storefront_fqdn}"

info "public application smoke test: ${STOREFRONT_URL}"
"$ROOT/scripts/cd/smoke-test.sh"

pass "FINAL CLOUDMART SYSTEM ACCEPTANCE"
