#!/usr/bin/env bash
# Purpose: Deletes the separately bootstrapped Terraform-state storage resources after workload teardown.
# Workflow: Uses explicit confirmation and Azure CLI checks so remote state is removed only at the end of the course lifecycle.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

RG="${TFSTATE_RESOURCE_GROUP:-rg-cloudmart-tfstate-eastus}"

exists="$(az group exists --name "$RG")"
[[ "$exists" == "true" ]] || {
  info "$RG already absent"
  exit 0
}

printf 'About to delete Terraform-state bootstrap resource group: %s\n' "$RG"
printf 'This removes the remote state storage after the workload has already been destroyed.\n'

[[ "${CONFIRM_TFSTATE_DESTROY:-}" == "$RG" ]] || \
  fail "set CONFIRM_TFSTATE_DESTROY=$RG to proceed"

az group delete \
  --name "$RG" \
  --yes \
  --no-wait

pass "Terraform-state bootstrap deletion submitted"

if [[ "${WAIT_FOR_TFSTATE_DESTROY:-0}" == "1" ]]; then
  info "waiting for resource-group deletion"

  for _ in $(seq 1 60); do
    exists="$(az group exists --name "$RG")"
    if [[ "$exists" == "false" ]]; then
      pass "Terraform-state bootstrap removed"
      exit 0
    fi
    sleep 10
  done

  fail "timed out waiting for $RG deletion"
fi
