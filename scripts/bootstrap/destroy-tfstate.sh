#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
RG="${TFSTATE_RESOURCE_GROUP:-rg-cloudmart-tfstate-eastus}"
exists="$(az group exists -n "$RG")"
[[ "$exists" == "true" ]] || { info "$RG already absent"; exit 0; }
printf 'About to delete Terraform-state bootstrap resource group: %s\n' "$RG"
[[ "${CONFIRM_TFSTATE_DESTROY:-}" == "$RG" ]] || fail "set CONFIRM_TFSTATE_DESTROY=$RG to proceed"
az group delete -n "$RG" --yes --no-wait
pass "Terraform-state bootstrap deletion submitted"
