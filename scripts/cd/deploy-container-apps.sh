#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
require_cmd jq
require_env ACR_LOGIN_SERVER
MANIFEST="${1:-release-manifest.json}"
[[ -f "$MANIFEST" ]] || fail "release manifest not found: $MANIFEST"
RG="$(cloudmart_rg)"
REVISION_SUFFIX="${REVISION_SUFFIX:-sha-$(jq -r '.gitSha' "$MANIFEST" | cut -c1-12)}"

map=(
  "storefront|ca-storefront-training"
  "web-bff|ca-web-bff-training"
  "catalog|ca-catalog-training"
  "cart|ca-cart-training"
  "order|ca-order-training"
  "inventory|ca-inventory-training"
  "payment|ca-payment-training"
  "notification|ca-notification-training"
)
for item in "${map[@]}"; do
  IFS='|' read -r key app <<<"$item"
  repo="$(jq -r ".images[\"$key\"].repository" "$MANIFEST")"
  digest="$(jq -r ".images[\"$key\"].digest" "$MANIFEST")"
  [[ "$repo" != null && "$digest" == sha256:* ]] || fail "manifest entry invalid for $key"
  info "deploying $app -> $repo@$digest"
  az containerapp update -g "$RG" -n "$app" --image "$ACR_LOGIN_SERVER/$repo@$digest" --revision-suffix "$REVISION_SUFFIX" >/dev/null
  pass "$app update submitted"
done
