#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
RG="$(cloudmart_rg)"
apps=(ca-storefront-training ca-web-bff-training ca-catalog-training ca-cart-training ca-order-training ca-inventory-training ca-payment-training ca-notification-training)
for app in "${apps[@]}"; do
  info "$app"
  az containerapp show -g "$RG" -n "$app" \
    --query 'properties.template.containers[0].env[].{Name:name,Value:value,SecretRef:secretRef}' -o table
  # Known sensitive variables may not be populated directly.
  bad="$(az containerapp show -g "$RG" -n "$app" --query "properties.template.containers[0].env[?(name=='DATABASE_URL' || name=='REDIS_PASSWORD' || name=='KAFKA_SASL_PASSWORD') && value!=null].name" -o tsv)"
  [[ -z "$bad" ]] || fail "$app exposes sensitive env value directly: $bad"
  pass "$app sensitive env classification"
done
