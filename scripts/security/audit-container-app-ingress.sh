#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
RG="$(cloudmart_rg)"
check() {
  local app="$1" expected="$2" external target
  external="$(az containerapp show -g "$RG" -n "$app" --query 'properties.configuration.ingress.external' -o tsv 2>/dev/null || true)"
  target="$(az containerapp show -g "$RG" -n "$app" --query 'properties.configuration.ingress.targetPort' -o tsv 2>/dev/null || true)"
  case "$expected" in
    external) [[ "$external" == "true" ]] || fail "$app expected external ingress" ;;
    internal) [[ "$external" == "false" && -n "$target" ]] || fail "$app expected internal ingress" ;;
    disabled) [[ -z "$external" && -z "$target" ]] || fail "$app expected ingress disabled" ;;
  esac
  pass "$app $expected"
}
check ca-storefront-training external
check ca-web-bff-training internal
check ca-catalog-training internal
check ca-cart-training internal
check ca-order-training internal
check ca-inventory-training disabled
check ca-payment-training disabled
check ca-notification-training disabled
