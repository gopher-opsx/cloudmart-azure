#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_cmd jq

MANIFEST="${1:-release-manifest.json}"
[[ -f "$MANIFEST" ]] || fail "release manifest not found: $MANIFEST"

RG="$(cloudmart_rg)"
GIT_SHA="$(jq -r '.gitSha' "$MANIFEST")"
[[ "$GIT_SHA" != null && -n "$GIT_SHA" ]] || fail "manifest gitSha missing"
REVISION_SUFFIX="${REVISION_SUFFIX:-sha-$(cut -c1-12 <<<"$GIT_SHA")}"
SKIP_STOREFRONT="${SKIP_STOREFRONT:-0}"

apps=(
  "storefront|ca-storefront-training"
  "web-bff|ca-web-bff-training"
  "catalog-service|ca-catalog-training"
  "cart-service|ca-cart-training"
  "order-service|ca-order-training"
  "inventory-service|ca-inventory-training"
  "payment-service|ca-payment-training"
  "notification-service|ca-notification-training"
)

for item in "${apps[@]}"; do
  IFS='|' read -r key app <<<"$item"

  if [[ "$key" == "storefront" && "$SKIP_STOREFRONT" == "1" ]]; then
    info "Storefront skipped for candidate-safe rollout"
    continue
  fi

  image="$(jq -r ".images[\"${key}\"].immutableReference" "$MANIFEST")"
  [[ "$image" == *@sha256:* ]] || fail "manifest immutableReference invalid for ${key}"

  info "deploying ${app} -> ${image}"
  az containerapp update \
    --resource-group "$RG" \
    --name "$app" \
    --image "$image" \
    --revision-suffix "$REVISION_SUFFIX" \
    --only-show-errors >/dev/null

  pass "${app} update submitted"
done
