#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${ROOT}/scripts/lib/course-common.sh"

require_cmd az

RG="$(cloudmart_rg)"

apps=(
  ca-storefront-training
  ca-web-bff-training
  ca-catalog-training
  ca-cart-training
  ca-order-training
  ca-inventory-training
  ca-payment-training
  ca-notification-training
)

for app in "${apps[@]}"; do
  identity_ids="$(
    az containerapp show \
      --resource-group "${RG}" \
      --name "${app}" \
      --query 'identity.userAssignedIdentities | keys(@)' \
      -o tsv
  )"

  [[ -n "${identity_ids}" ]] || fail "${app} has no user-assigned identity"

  count="$(wc -w <<<"${identity_ids}" | tr -d ' ')"
  [[ "${count}" == "1" ]] || fail "${app} should have exactly one user-assigned identity"

  pass "${app} one user-assigned identity"
done

pass "8 Container Apps have exactly one user-assigned identity"
