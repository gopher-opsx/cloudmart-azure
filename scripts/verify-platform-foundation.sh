#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
RG="$(cloudmart_rg)"

check_resource() {
  local type="$1" query="$2" label="$3"
  local count
  count="$(az resource list -g "$RG" --resource-type "$type" --query "$query | length(@)" -o tsv 2>/dev/null || echo 0)"
  [[ "$count" -ge 1 ]] || fail "$label not found in $RG"
  pass "$label"
}

az group show -n "$RG" >/dev/null || fail "resource group $RG not found"
pass "resource group"
check_resource Microsoft.ContainerRegistry/registries "[?contains(name, 'cloudmart') || contains(name, 'acr')]" "container registry"
check_resource Microsoft.OperationalInsights/workspaces "[@]" "Log Analytics workspace"
check_resource Microsoft.App/managedEnvironments "[@]" "Container Apps environment"
check_resource Microsoft.Insights/components "[@]" "Application Insights"
check_resource Microsoft.KeyVault/vaults "[@]" "Key Vault"
ids="$(az identity list -g "$RG" --query 'length(@)' -o tsv)"
[[ "$ids" -ge 8 ]] || fail "expected at least 8 user-assigned identities, found $ids"
pass "8 workload identities"
