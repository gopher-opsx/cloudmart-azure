#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd docker
files=(
  apps/storefront/Dockerfile
  services/web-bff/Dockerfile
  services/catalog-service/Dockerfile
  services/cart-service/Dockerfile
  services/order-service/Dockerfile
  services/inventory-service/Dockerfile
  services/payment-service/Dockerfile
  services/notification-service/Dockerfile
)
for file in "${files[@]}"; do
  info "validating $file"
  docker buildx build --platform linux/amd64 --file "$ROOT/$file" --load --tag "cloudmart-ci:$(basename "$(dirname "$file")")" "$ROOT" >/dev/null
  pass "$file"
done
