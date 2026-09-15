#!/usr/bin/env bash
# Purpose: Runs the synchronous post-deployment smoke gate through the public Storefront URL.
# Workflow: Validates HTTPS, health, products, cart add/read/cleanup, and Order API reachability using a temporary customer.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd curl
require_env STOREFRONT_URL

BASE="${STOREFRONT_URL%/}"
CUSTOMER_ID="${SMOKE_CUSTOMER_ID:-smoke-$(date +%s)-${RANDOM}}"
PRODUCT_ID="${SMOKE_PRODUCT_ID:-prod-001}"

retry() {
  local attempts="${1:-12}"
  local sleep_s="${2:-5}"
  shift 2

  local i
  for ((i=1; i<=attempts; i++)); do
    if "$@"; then
      return 0
    fi
    sleep "$sleep_s"
  done

  return 1
}

retry 12 5 curl -fsS "$BASE/" >/dev/null \
  || fail "Storefront HTTPS"
pass "Storefront HTTPS"

retry 12 5 curl -fsS "$BASE/healthz" >/dev/null \
  || fail "Health"
pass "Health"

products="$(curl -fsS "$BASE/api/products")" \
  || fail "Products"

[[ -n "$products" ]] \
  || fail "Products returned empty response"

pass "Products"

curl -fsS \
  -X POST \
  -H "X-Customer-ID: $CUSTOMER_ID" \
  -H "Content-Type: application/json" \
  -d "{\"productId\":\"${PRODUCT_ID}\",\"quantity\":1}" \
  "$BASE/api/cart/items" \
  >/dev/null \
  || fail "Cart add"

pass "Cart add"

cart="$(
  curl -fsS \
    -H "X-Customer-ID: $CUSTOMER_ID" \
    "$BASE/api/cart"
)" || fail "Cart read"

[[ "$cart" == *"\"productId\":\"${PRODUCT_ID}\""* ]] \
  || fail "Cart does not contain smoke product"

pass "Cart read"

curl -fsS \
  -X DELETE \
  -H "X-Customer-ID: $CUSTOMER_ID" \
  "$BASE/api/cart" \
  >/dev/null \
  || fail "Cart cleanup"

pass "Cart cleanup"

orders="$(
  curl -fsS \
    -H "X-Customer-ID: $CUSTOMER_ID" \
    "$BASE/api/orders"
)" || fail "Order read"

[[ "$orders" == \[* ]] \
  || fail "Order endpoint did not return a JSON array"

pass "Order read"

if [[ -n "${SMOKE_ORDER_PAYLOAD:-}" ]]; then
  curl -fsS \
    -H "Content-Type: application/json" \
    -H "X-Customer-ID: $CUSTOMER_ID" \
    -d "$SMOKE_ORDER_PAYLOAD" \
    "$BASE/api/orders" \
    >/dev/null \
    || fail "Order mutation"

  pass "Order mutation"
fi

pass "Smoke test complete"
