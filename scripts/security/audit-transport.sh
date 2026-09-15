#!/usr/bin/env bash
# Purpose: Runs transport-security checks for the CloudMart ingress path.
# Workflow: Combines HTTPS/ingress verification so external traffic follows the intended secure boundary.

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${ROOT}/scripts/lib/course-common.sh"

require_cmd az
require_cmd curl

RG="$(cloudmart_rg)"

storefront_fqdn="$(
  az containerapp show \
    --resource-group "${RG}" \
    --name ca-storefront-training \
    --query 'properties.configuration.ingress.fqdn' \
    -o tsv
)"

[[ -n "${storefront_fqdn}" ]] || fail "Storefront FQDN missing"

curl -fsS "https://${storefront_fqdn}/healthz" >/dev/null
pass "Storefront HTTPS"

location="$(
  curl -sSI "http://${storefront_fqdn}/healthz" \
    | tr -d '\r' \
    | awk 'tolower($1)=="location:" {print $2; exit}'
)"

[[ "${location}" == https://* ]] || fail "Storefront HTTP did not redirect to HTTPS"
pass "Storefront HTTP -> HTTPS redirect"

bash "${ROOT}/scripts/security/audit-container-app-ingress.sh"

pass "NETWORK AND TRANSPORT"
