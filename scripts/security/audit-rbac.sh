#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
RG="$(cloudmart_rg)"
apps=(storefront web-bff catalog cart order inventory payment notification)
for key in "${apps[@]}"; do
  app="ca-${key}-training"
  principal="$(az containerapp show -g "$RG" -n "$app" --query 'identity.userAssignedIdentities | keys(@)[0]' -o tsv)"
  [[ -n "$principal" ]] || fail "$app identity missing"
  pid="$(az identity show --ids "$principal" --query principalId -o tsv)"
  broad="$(az role assignment list --assignee-object-id "$pid" --all --query "[?roleDefinitionName=='Owner' || roleDefinitionName=='Contributor' || roleDefinitionName=='User Access Administrator'].roleDefinitionName" -o tsv)"
  [[ -z "$broad" ]] || fail "$app has prohibited broad role: $broad"
  pass "$app no broad workload role"
done
