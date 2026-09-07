#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd curl
require_env STOREFRONT_URL
BASE="${STOREFRONT_URL%/}"

retry() {
  local attempts="${1:-12}" sleep_s="${2:-5}"; shift 2
  local i
  for ((i=1;i<=attempts;i++)); do
    if "$@"; then return 0; fi
    sleep "$sleep_s"
  done
  return 1
}

retry 12 5 curl -fsS "$BASE/" >/dev/null || fail "Storefront HTTPS"
pass "Storefront HTTPS"
retry 12 5 curl -fsS "$BASE/healthz" >/dev/null || fail "Health"
pass "Health"
products="$(curl -fsS "$BASE/api/products")" || fail "Products"
[[ -n "$products" ]] || fail "Products returned empty response"
pass "Products"

# Cart API schemas can evolve; use the repository's documented BFF API contract when available.
if curl -fsS "$BASE/api/cart" >/dev/null 2>&1; then pass "Cart read"; else info "Cart read requires session/cart identifier; run repository-specific cart smoke extension"; fi

# Order is intentionally a controlled minimum check. Full Saga regression remains final-project validation.
if [[ -n "${SMOKE_ORDER_PAYLOAD:-}" ]]; then
  curl -fsS -H 'Content-Type: application/json' -d "$SMOKE_ORDER_PAYLOAD" "$BASE/api/orders" >/dev/null || fail "Order API"
  pass "Order API"
else
  info "SMOKE_ORDER_PAYLOAD not set; Order API mutation skipped"
fi
pass "Smoke test complete"
