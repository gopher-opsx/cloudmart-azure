#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
RG="$(cloudmart_rg)"
apps=(ca-storefront-training ca-web-bff-training ca-catalog-training ca-cart-training ca-order-training ca-inventory-training ca-payment-training ca-notification-training)
for app in "${apps[@]}"; do
  ids="$(az containerapp show -g "$RG" -n "$app" --query 'identity.userAssignedIdentities' -o json)"
  [[ "$ids" != "{}" && "$ids" != "null" ]] || fail "$app has no user-assigned identity"
  pass "$app user-assigned identity"
done
pass "8 Container Apps have user-assigned identities"
