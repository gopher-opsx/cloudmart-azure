#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az

AZURE_LOCATION="${AZURE_LOCATION:-eastus}"
TFSTATE_RESOURCE_GROUP="${TFSTATE_RESOURCE_GROUP:-rg-cloudmart-tfstate-eastus}"
TFSTATE_CONTAINER="${TFSTATE_CONTAINER:-tfstate}"
TFSTATE_STORAGE_ACCOUNT="${TFSTATE_STORAGE_ACCOUNT:-}"

require_env TFSTATE_STORAGE_ACCOUNT

if ! [[ "$TFSTATE_STORAGE_ACCOUNT" =~ ^[a-z0-9]{3,24}$ ]]; then
  fail "TFSTATE_STORAGE_ACCOUNT must be 3-24 lowercase letters/numbers"
fi

account_state="$(az account show --query state -o tsv)"
[[ "$account_state" == "Enabled" ]] || fail "active Azure subscription is not enabled"

info "Creating or updating Terraform-state resource group: $TFSTATE_RESOURCE_GROUP"
az group create \
  --name "$TFSTATE_RESOURCE_GROUP" \
  --location "$AZURE_LOCATION" \
  --tags \
    application=cloudmart \
    environment=training \
    purpose=terraform-state \
    managed-by=azure-cli \
  --output none

if az storage account show \
  --name "$TFSTATE_STORAGE_ACCOUNT" \
  --resource-group "$TFSTATE_RESOURCE_GROUP" \
  --output none 2>/dev/null; then
  info "Storage account already exists: $TFSTATE_STORAGE_ACCOUNT"
else
  info "Creating Terraform-state storage account: $TFSTATE_STORAGE_ACCOUNT"
  az storage account create \
    --name "$TFSTATE_STORAGE_ACCOUNT" \
    --resource-group "$TFSTATE_RESOURCE_GROUP" \
    --location "$AZURE_LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --https-only true \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --allow-shared-key-access false \
    --output none
fi

user_object_id="$(az ad signed-in-user show --query id -o tsv)"
storage_scope="$(az storage account show \
  --name "$TFSTATE_STORAGE_ACCOUNT" \
  --resource-group "$TFSTATE_RESOURCE_GROUP" \
  --query id \
  -o tsv)"

assignment_count="$(az role assignment list \
  --assignee-object-id "$user_object_id" \
  --scope "$storage_scope" \
  --role "Storage Blob Data Contributor" \
  --query 'length(@)' \
  -o tsv)"

if [[ "$assignment_count" == "0" ]]; then
  info "Granting Storage Blob Data Contributor to the signed-in user"
  az role assignment create \
    --assignee-object-id "$user_object_id" \
    --assignee-principal-type User \
    --role "Storage Blob Data Contributor" \
    --scope "$storage_scope" \
    --output none
else
  info "Required storage data role assignment already exists"
fi

info "Enabling blob versioning and seven-day delete retention"
az storage account blob-service-properties update \
  --account-name "$TFSTATE_STORAGE_ACCOUNT" \
  --resource-group "$TFSTATE_RESOURCE_GROUP" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 7 \
  --enable-container-delete-retention true \
  --container-delete-retention-days 7 \
  --output none

info "Creating tfstate container with Microsoft Entra authentication"
container_created=false
for attempt in 1 2 3 4 5 6; do
  if az storage container create \
    --name "$TFSTATE_CONTAINER" \
    --account-name "$TFSTATE_STORAGE_ACCOUNT" \
    --auth-mode login \
    --output none 2>/dev/null; then
    container_created=true
    break
  fi

  info "Blob data permission may still be propagating (attempt $attempt/6); retrying in 10 seconds"
  sleep 10
done

[[ "$container_created" == "true" ]] || fail "unable to create/access tfstate container after role propagation retries"

pass "Terraform remote-state backend is ready"
printf '\nBackend values for training.azurerm.tfbackend:\n'
printf 'resource_group_name  = "%s"\n' "$TFSTATE_RESOURCE_GROUP"
printf 'storage_account_name = "%s"\n' "$TFSTATE_STORAGE_ACCOUNT"
printf 'container_name       = "%s"\n' "$TFSTATE_CONTAINER"
printf 'key                  = "cloudmart/training/terraform.tfstate"\n'
printf 'use_azuread_auth     = true\n'
printf 'use_cli              = true\n'
