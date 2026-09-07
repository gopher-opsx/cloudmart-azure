#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
require_env GITHUB_REPOSITORY
require_env AZURE_SUBSCRIPTION_ID
APP_DISPLAY_NAME="${APP_DISPLAY_NAME:-sp-cloudmart-github-training}"
GITHUB_ENVIRONMENT="${GITHUB_ENVIRONMENT:-training}"
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
[[ -n "$sp_id" ]] || sp_id="$(az ad sp create --id "$app_id" --query id -o tsv)"

cred_name="github-${GITHUB_ENVIRONMENT}"
existing="$(az ad app federated-credential list --id "$object_id" --query "[?name=='$cred_name'] | length(@)" -o tsv)"
if [[ "$existing" == "0" ]]; then
  payload="$(mktemp)"
  cat > "$payload" <<EOF
{"name":"$cred_name","issuer":"https://token.actions.githubusercontent.com","subject":"$SUBJECT","description":"CloudMart GitHub Actions $GITHUB_ENVIRONMENT","audiences":["api://AzureADTokenExchange"]}
EOF
  az ad app federated-credential create --id "$object_id" --parameters "$payload" >/dev/null
  rm -f "$payload"
  pass "GitHub federated credential created"
else
  info "federated credential already exists"
fi

printf 'AZURE_CLIENT_ID=%s\nAZURE_TENANT_ID=%s\nAZURE_SUBSCRIPTION_ID=%s\nOIDC_SUBJECT=%s\n' "$app_id" "$(az account show --query tenantId -o tsv)" "$AZURE_SUBSCRIPTION_ID" "$SUBJECT"
info "Assign AcrPush at ACR scope and the prepared Container Apps deployment role at training scope after the Azure resources exist."
