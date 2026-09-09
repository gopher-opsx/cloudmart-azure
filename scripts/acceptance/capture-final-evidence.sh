#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_cmd git

RG="$(cloudmart_rg)"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${FINAL_EVIDENCE_DIR:-$ROOT/.course/final-evidence/$STAMP}"

mkdir -p "$OUT"

git -C "$ROOT" rev-parse HEAD > "$OUT/git-commit.txt"
git -C "$ROOT" status --short > "$OUT/git-status.txt"

az account show \
  --query '{subscription:name,tenantId:tenantId}' \
  -o json > "$OUT/azure-context.json"

az resource list \
  --resource-group "$RG" \
  --query '[].{name:name,type:type,location:location}' \
  -o json > "$OUT/resources.json"

az containerapp list \
  --resource-group "$RG" \
  --query '[].{
    name:name,
    runningStatus:properties.runningStatus,
    latestRevisionName:properties.latestRevisionName,
    ingressExternal:properties.configuration.ingress.external,
    ingressFqdn:properties.configuration.ingress.fqdn
  }' \
  -o json > "$OUT/container-apps.json"

az monitor metrics list-definitions \
  --resource "$(az containerapp show -g "$RG" -n ca-storefront-training --query id -o tsv)" \
  --query '[].name.value' \
  -o json > "$OUT/storefront-metric-definitions.json"

"$ROOT/scripts/security/verify-security-baseline.sh" \
  > "$OUT/security-baseline.txt" 2>&1

"$ROOT/scripts/cd/verify-release.sh" \
  > "$OUT/release-verification.txt" 2>&1

"$ROOT/scripts/container-apps/verify-backend-runtime.sh" \
  > "$OUT/backend-runtime.txt" 2>&1

cat > "$OUT/README.txt" <<EOF
CloudMart final project evidence
Captured UTC: ${STAMP}

This directory intentionally excludes:
- Terraform state
- Key Vault secret values
- database passwords
- Redis access keys
- Event Hubs connection strings
- OIDC tokens
- Azure access tokens

Review evidence before sharing publicly.
EOF

printf '%s\n' "$OUT"
pass "SANITIZED FINAL EVIDENCE CAPTURED"
