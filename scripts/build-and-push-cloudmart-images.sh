#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd git
require_cmd docker

RELEASE_ENV="$ROOT/platform/images/release.env"
[[ -f "$RELEASE_ENV" ]] || fail "missing $RELEASE_ENV (copy release.env.example and populate it first)"
# shellcheck disable=SC1090
source "$RELEASE_ENV"

require_env CLOUDMART_ACR_LOGIN_SERVER
require_env CLOUDMART_IMAGE_VERSION
require_env CLOUDMART_GIT_SHA
require_env CLOUDMART_SHA_TAG

CURRENT_SHA="$(git -C "$ROOT" rev-parse HEAD)"
[[ "$CURRENT_SHA" == "$CLOUDMART_GIT_SHA" ]] || \
  fail "release.env Git SHA does not match the current checkout; regenerate release metadata before publishing"

components=(
  "storefront|cloudmart/storefront|apps/storefront/Dockerfile"
  "web-bff|cloudmart/web-bff|services/web-bff/Dockerfile"
  "catalog-service|cloudmart/catalog-service|services/catalog-service/Dockerfile"
  "cart-service|cloudmart/cart-service|services/cart-service/Dockerfile"
  "order-service|cloudmart/order-service|services/order-service/Dockerfile"
  "inventory-service|cloudmart/inventory-service|services/inventory-service/Dockerfile"
  "payment-service|cloudmart/payment-service|services/payment-service/Dockerfile"
  "notification-service|cloudmart/notification-service|services/notification-service/Dockerfile"
)

info "Building CloudMart ${CLOUDMART_IMAGE_VERSION} from ${CLOUDMART_GIT_SHA}"
info "Registry: ${CLOUDMART_ACR_LOGIN_SERVER}"

for item in "${components[@]}"; do
  IFS='|' read -r component repository dockerfile <<<"$item"
  image="${CLOUDMART_ACR_LOGIN_SERVER}/${repository}"

  [[ -f "$ROOT/$dockerfile" ]] || fail "Dockerfile not found: $dockerfile"

  info "[$component] build + push"
  docker buildx build \
    --platform linux/amd64 \
    --file "$ROOT/$dockerfile" \
    --label "org.opencontainers.image.revision=${CLOUDMART_GIT_SHA}" \
    --label "org.opencontainers.image.version=${CLOUDMART_IMAGE_VERSION}" \
    --tag "${image}:${CLOUDMART_IMAGE_VERSION}" \
    --tag "${image}:${CLOUDMART_SHA_TAG}" \
    --push \
    "$ROOT"

  pass "$component published"
done

pass "CloudMart release ${CLOUDMART_IMAGE_VERSION} published with tag ${CLOUDMART_SHA_TAG}"
