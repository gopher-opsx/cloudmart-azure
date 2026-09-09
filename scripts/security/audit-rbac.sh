#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${ROOT}/scripts/lib/course-common.sh"

require_cmd az

RG="$(cloudmart_rg)"
ACR_NAME="$(cloudmart_acr_name)"
KEY_VAULT="$(cloudmart_key_vault_name)"

ACR_ID="$(az acr show --name "${ACR_NAME}" --query id -o tsv)"
KEY_VAULT_ID="$(az keyvault show --name "${KEY_VAULT}" --query id -o tsv)"

declare -A identity_resource_names=(
  [storefront]="id-cloudmart-storefront-training-eastus"
  [web-bff]="id-cloudmart-web-bff-training-eastus"
  [catalog]="id-cloudmart-catalog-training-eastus"
  [cart]="id-cloudmart-cart-training-eastus"
  [order]="id-cloudmart-order-training-eastus"
  [inventory]="id-cloudmart-inventory-training-eastus"
  [payment]="id-cloudmart-payment-training-eastus"
  [notification]="id-cloudmart-notification-training-eastus"
)

backend=(catalog cart order inventory payment notification)

for key in "${!identity_resource_names[@]}"; do
  identity_name="${identity_resource_names[$key]}"
  pid="$(
    az identity show \
      --resource-group "${RG}" \
      --name "${identity_name}" \
      --query principalId \
      -o tsv
  )"

  broad="$(
    az role assignment list \
      --assignee-object-id "${pid}" \
      --all \
      --query "[?roleDefinitionName=='Owner' || roleDefinitionName=='Contributor' || roleDefinitionName=='User Access Administrator'].roleDefinitionName" \
      -o tsv
  )"
  [[ -z "${broad}" ]] || fail "${key} has prohibited broad role: ${broad}"

  acr_pull="$(
    az role assignment list \
      --assignee-object-id "${pid}" \
      --scope "${ACR_ID}" \
      --query "[?roleDefinitionName=='AcrPull'] | length(@)" \
      -o tsv
  )"
  [[ "${acr_pull}" == "1" ]] || fail "${key} requires one AcrPull role at ACR"

  pass "${key} AcrPull + no broad role"
done

for key in "${backend[@]}"; do
  identity_name="${identity_resource_names[$key]}"
  pid="$(
    az identity show \
      --resource-group "${RG}" \
      --name "${identity_name}" \
      --query principalId \
      -o tsv
  )"

  readers="$(
    az role assignment list \
      --assignee-object-id "${pid}" \
      --scope "${KEY_VAULT_ID}" \
      --query "[?roleDefinitionName=='Key Vault Secrets User'] | length(@)" \
      -o tsv
  )"

  [[ "${readers}" == "1" ]] || fail "${key} requires one Key Vault Secrets User role"
done

for key in storefront web-bff; do
  identity_name="${identity_resource_names[$key]}"
  pid="$(
    az identity show \
      --resource-group "${RG}" \
      --name "${identity_name}" \
      --query principalId \
      -o tsv
  )"

  readers="$(
    az role assignment list \
      --assignee-object-id "${pid}" \
      --scope "${KEY_VAULT_ID}" \
      --query "[?roleDefinitionName=='Key Vault Secrets User'] | length(@)" \
      -o tsv
  )"

  [[ "${readers}" == "0" ]] || fail "${key} must not have a Key Vault secret-read role"
  pass "${key} no Key Vault secret role"
done

pass "CLOUDMART LEAST-PRIVILEGE RBAC"
