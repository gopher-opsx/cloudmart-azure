#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

RG="$(cloudmart_rg)"
TFSTATE_RG="${TFSTATE_RESOURCE_GROUP:-rg-cloudmart-tfstate-eastus}"

exists="$(az group exists --name "$RG")"
[[ "$exists" == "false" ]] || fail "workload resource group still exists: $RG"
pass "workload resource group removed"

remaining="$(
  az resource list \
    --query "[?resourceGroup!='${TFSTATE_RG}'].[name,type,resourceGroup]" \
    -o tsv \
  | grep -i 'cloudmart' || true
)"

[[ -z "$remaining" ]] || {
  printf 'Remaining CloudMart workload resources:\n%s\n' "$remaining" >&2
  fail "active CloudMart workload resources still remain"
}

pass "no active CloudMart workload resources"
pass "CLOUDMART WORKLOAD DESTROY VERIFIED"
