#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_env GITHUB_REPOSITORY
require_env AZURE_SUBSCRIPTION_ID
require_env ACR_NAME

APP_DISPLAY_NAME="${APP_DISPLAY_NAME:-sp-cloudmart-github-training}"
GITHUB_ENVIRONMENT="${GITHUB_ENVIRONMENT:-training}"
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-cloudmart-training-eastus}"
SUBJECT="${GITHUB_OIDC_SUBJECT:-repo:${GITHUB_REPOSITORY}:environment:${GITHUB_ENVIRONMENT}}"

app_id="$(az ad app list --display-name "$APP_DISPLAY_NAME" --query '[0].appId' -o tsv)"
if [[ -z "$app_id" ]]; then
  app_id="$(az ad app create --display-name "$APP_DISPLAY_NAME" --query appId -o tsv)"
  pass "Entra application created"
else
  info "Entra application already exists"
fi

object_id="$(az ad app show --id "$app_id" --query id -o tsv)"
sp_id="$(az ad sp list --filter "appId eq '$app_id'" --query '[0].id' -o tsv)"
if [[ -z "$sp_id" ]]; then
  sp_id="$(az ad sp create --id "$app_id" --query id -o tsv)"
  pass "service principal created"
fi

cred_name="github-${GITHUB_ENVIRONMENT}"
existing="$(
  az ad app federated-credential list \
    --id "$object_id" \
    --query "[?name=='$cred_name'] | length(@)" \
    -o tsv
)"

if [[ "$existing" == "0" ]]; then
  payload="$(mktemp)"
  cat > "$payload" <<EOF
{
  "name": "$cred_name",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "$SUBJECT",
  "description": "CloudMart GitHub Actions ${GITHUB_ENVIRONMENT}",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF
  az ad app federated-credential create \
    --id "$object_id" \
    --parameters "$payload" >/dev/null
  rm -f "$payload"
  pass "GitHub federated credential created"
else
  info "federated credential already exists"
fi

ACR_ID="$(az acr show --name "$ACR_NAME" --query id -o tsv)"
RG_ID="$(az group show --name "$RESOURCE_GROUP" --query id -o tsv)"

ensure_role() {
  local role="$1"
  local scope="$2"

  local count
  count="$(
    az role assignment list \
      --assignee-object-id "$sp_id" \
      --scope "$scope" \
      --query "[?roleDefinitionName=='${role}'] | length(@)" \
      -o tsv
  )"

  if [[ "$count" == "0" ]]; then
    az role assignment create \
      --assignee-object-id "$sp_id" \
      --assignee-principal-type ServicePrincipal \
      --role "$role" \
      --scope "$scope" >/dev/null
    pass "${role} assigned"
  else
    info "${role} already assigned"
  fi
}

ensure_role "AcrPush" "$ACR_ID"
ensure_role "Container Apps Contributor" "$RG_ID"

tenant_id="$(az account show --query tenantId -o tsv)"

cat <<EOF
AZURE_CLIENT_ID=${app_id}
AZURE_TENANT_ID=${tenant_id}
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}
ACR_NAME=${ACR_NAME}
RESOURCE_GROUP=${RESOURCE_GROUP}
OIDC_SUBJECT=${SUBJECT}
EOF

pass "GitHub OIDC deployment identity ready"
