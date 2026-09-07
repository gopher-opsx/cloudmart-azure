#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
RG="$(cloudmart_rg)"
apps=(ca-storefront-training ca-web-bff-training ca-catalog-training ca-cart-training ca-order-training ca-inventory-training ca-payment-training ca-notification-training)
for app in "${apps[@]}"; do
  state="$(az containerapp show -g "$RG" -n "$app" --query properties.runningStatus -o tsv)"
  [[ "$state" == "Running" ]] || fail "$app runningStatus=$state"
  rev="$(az containerapp revision list -g "$RG" -n "$app" --query '[?properties.active].name | [0]' -o tsv)"
  [[ -n "$rev" ]] || fail "$app has no active revision"
  pass "$app $rev"
done
