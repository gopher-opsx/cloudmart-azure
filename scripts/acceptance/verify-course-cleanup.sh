#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

active_groups="$(
  az group list \
    --query "[?contains(to_lower(name), 'cloudmart')].name" \
    -o tsv
)"
[[ -z "$active_groups" ]] || {
  printf 'Remaining CloudMart resource groups:\n%s\n' "$active_groups" >&2
  fail "course resource groups remain"
}
pass "no active CloudMart resource groups"

active_resources="$(
  az resource list \
    --query "[?contains(to_lower(name), 'cloudmart')].{name:name,type:type,resourceGroup:resourceGroup}" \
    -o tsv
)"
[[ -z "$active_resources" ]] || {
  printf 'Remaining CloudMart resources:\n%s\n' "$active_resources" >&2
  fail "course resources remain"
}
pass "no active CloudMart resources"

deleted_vaults="$(
  az keyvault list-deleted \
    --query "[?contains(to_lower(name), 'cloudmart')].name" \
    -o tsv
)"

if [[ -n "$deleted_vaults" ]]; then
  info "soft-deleted CloudMart Key Vault(s) remain:"
  printf '%s\n' "$deleted_vaults"
  info "For the disposable course environment, purge only after confirming recovery is not required."
else
  pass "no soft-deleted CloudMart Key Vault remains"
fi

pass "COURSE ACTIVE-RESOURCE CLEANUP VERIFIED"
