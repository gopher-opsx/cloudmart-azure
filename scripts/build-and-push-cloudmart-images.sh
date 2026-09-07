#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd git
require_cmd docker
if [[ -f "$ROOT/platform/images/release.env" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT/platform/images/release.env"
fi
require_env ACR_LOGIN_SERVER

SHORT_SHA="$(git -C "$ROOT" rev-parse --short=12 HEAD)"
SHA_TAG="sha-${SHORT_SHA}"
VERSION_TAG="${RELEASE_VERSION:-1.0.0}"

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

info "Building CloudMart release $VERSION_TAG / $SHA_TAG"
for item in "${components[@]}"; do
  IFS='|' read -r component repo dockerfile <<<"$item"
  image="$ACR_LOGIN_SERVER/$repo"
  info "[$component] build + push"
  docker buildx build \
    --platform linux/amd64 \
    --file "$ROOT/$dockerfile" \
    --label "org.opencontainers.image.revision=$(git -C "$ROOT" rev-parse HEAD)" \
    --label "org.opencontainers.image.version=$VERSION_TAG" \
    --tag "$image:$VERSION_TAG" \
    --tag "$image:$SHA_TAG" \
    --push \
    "$ROOT"
  pass "$component published"
done
printf 'RELEASE_VERSION=%s\nSHORT_SHA=%s\nSHA_TAG=%s\n' "$VERSION_TAG" "$SHORT_SHA" "$SHA_TAG"
