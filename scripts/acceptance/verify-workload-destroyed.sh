#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

RG="$(cloudmart_rg)"

exists="$(az group exists --name "$RG")"
[[ "$exists" == "false" ]] || fail "workload resource group still exists: $RG"
pass "workload resource group removed"

remaining="$(
  az resource list \
    --query "[?contains(to_lower(name), 'cloudmart') && resourceGroup!='rg-cloudmart-tfstate-eastus'] | length(@)" \
    -o tsv
)"
[[ "$remaining" == "0" ]] || fail "${remaining} active CloudMart resource(s) still remain"
pass "no active CloudMart workload resources"

pass "CLOUDMART WORKLOAD DESTROY VERIFIED"
