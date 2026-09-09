#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${ROOT}/scripts/lib/course-common.sh"

require_cmd az

RG="$(cloudmart_rg)"

backend_apps=(
  ca-catalog-training
  ca-cart-training
  ca-order-training
  ca-inventory-training
  ca-payment-training
  ca-notification-training
)

for app in "${backend_apps[@]}"; do
  json="$(
    az containerapp show \
      --resource-group "${RG}" \
      --name "${app}" \
      --query 'properties.configuration.secrets' \
      -o json
  )"

  # The Azure control plane should expose Key Vault references, not inline
  # application secret values, for the approved runtime secret names.
  if grep -q '"value"' <<<"${json}"; then
    fail "${app} contains an inline Container App secret value"
  fi

  if ! grep -q 'keyVaultUrl' <<<"${json}"; then
    fail "${app} does not expose a Key Vault secret reference"
  fi

  pass "${app} Key Vault secret references"
done

for app in ca-storefront-training ca-web-bff-training; do
  count="$(
    az containerapp show \
      --resource-group "${RG}" \
      --name "${app}" \
      --query 'length(properties.configuration.secrets || `[]`)' \
      -o tsv
  )"

  [[ "${count}" == "0" ]] || fail "${app} should not define application-data secrets"
  pass "${app} no application-data secrets"
done

pass "KEY VAULT RUNTIME REFERENCES"
