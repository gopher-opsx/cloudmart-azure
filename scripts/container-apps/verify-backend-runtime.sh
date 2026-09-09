#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${ROOT}/scripts/lib/course-common.sh"

require_cmd az

RG="$(cloudmart_rg)"

http_apps=(
  "ca-catalog-training"
  "ca-cart-training"
  "ca-order-training"
)

workers=(
  "ca-inventory-training"
  "ca-payment-training"
  "ca-notification-training"
)

for app in "${http_apps[@]}"; do
  state="$(az containerapp show -g "${RG}" -n "${app}" --query 'properties.provisioningState' -o tsv)"
  fqdn="$(az containerapp show -g "${RG}" -n "${app}" --query 'properties.configuration.ingress.fqdn' -o tsv)"
  external="$(az containerapp show -g "${RG}" -n "${app}" --query 'properties.configuration.ingress.external' -o tsv)"

  [[ "${state}" == "Succeeded" ]] || fail "${app} provisioningState=${state}"
  [[ -n "${fqdn}" ]] || fail "${app} internal FQDN missing"
  [[ "${external}" == "false" ]] || fail "${app} should use internal ingress"

  pass "${app} internal ingress ${fqdn}"
done

for app in "${workers[@]}"; do
  state="$(az containerapp show -g "${RG}" -n "${app}" --query 'properties.provisioningState' -o tsv)"
  target="$(az containerapp show -g "${RG}" -n "${app}" --query 'properties.configuration.ingress.targetPort' -o tsv 2>/dev/null || true)"

  [[ "${state}" == "Succeeded" ]] || fail "${app} provisioningState=${state}"
  [[ -z "${target}" ]] || fail "${app} unexpectedly has ingress"

  pass "${app} worker ingress disabled"
done

catalog_fqdn="$(az containerapp show -g "${RG}" -n ca-catalog-training --query 'properties.configuration.ingress.fqdn' -o tsv)"

info "Testing internal DNS + HTTPS from Order to Catalog"
az containerapp exec \
  -g "${RG}" \
  -n ca-order-training \
  --command "wget -qO- https://${catalog_fqdn}/healthz" \
  >/tmp/cloudmart-internal-health.txt

grep -q "ok" /tmp/cloudmart-internal-health.txt || fail "Order -> Catalog health request failed"
pass "Order -> Catalog internal service discovery"

pass "CLOUDMART BACKEND RUNTIME"
