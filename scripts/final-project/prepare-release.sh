#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TF_DIR="$ROOT/platform/terraform/environments/training"
source "$ROOT/scripts/lib/course-common.sh"

for cmd in git terraform az docker python; do
  require_cmd "$cmd"
done

require_env TF_VAR_postgresql_administrator_password

FINAL_RELEASE_VERSION="${FINAL_RELEASE_VERSION:-1.0.0}"

ACR_NAME="$(terraform -chdir="$TF_DIR" output -raw container_registry_name)"
[[ -n "$ACR_NAME" && "$ACR_NAME" != "null" ]] || \
  fail "ACR is not available. Apply stages/lesson-053.tfvars first."

ACR_LOGIN_SERVER="$(
  az acr show \
    --name "$ACR_NAME" \
    --query loginServer \
    -o tsv
)"
[[ -n "$ACR_LOGIN_SERVER" ]] || fail "could not resolve ACR login server"

POSTGRES_JSON="$(terraform -chdir="$TF_DIR" output -json postgresql)"
POSTGRESQL_HOST="$(
  python -c 'import json,sys; print(json.load(sys.stdin)["fqdn"])' <<<"$POSTGRES_JSON"
)"
POSTGRESQL_ADMIN="$(
  python -c 'import json,sys; print(json.load(sys.stdin)["administrator_login"])' <<<"$POSTGRES_JSON"
)"

GIT_SHA="$(git -C "$ROOT" rev-parse HEAD)"
SHA_TAG="sha-${GIT_SHA:0:12}"
RELEASE_ENV="$ROOT/platform/images/release.env"

cat > "$RELEASE_ENV" <<EOF
ACR_NAME=${ACR_NAME}
CLOUDMART_ACR_LOGIN_SERVER=${ACR_LOGIN_SERVER}
CLOUDMART_IMAGE_VERSION=${FINAL_RELEASE_VERSION}
CLOUDMART_GIT_SHA=${GIT_SHA}
CLOUDMART_SHA_TAG=${SHA_TAG}
EOF

pass "final-project release metadata generated"

az acr login --name "$ACR_NAME" >/dev/null
pass "Docker authenticated to ACR"

"$ROOT/scripts/build-and-push-cloudmart-images.sh"
"$ROOT/scripts/record-cloudmart-image-digests.sh"
"$ROOT/scripts/terraform/render-release-tfvars.sh"

POSTGRESQL_HOST="$POSTGRESQL_HOST" \
POSTGRESQL_ADMIN="$POSTGRESQL_ADMIN" \
POSTGRESQL_PASSWORD="$TF_VAR_postgresql_administrator_password" \
  "$ROOT/scripts/data/run-postgres-migrations.sh"

pass "FINAL PROJECT RELEASE PREPARED"
info "Fresh images exist in the recreated ACR."
info "Fresh immutable Terraform image inputs are ready."
info "Service databases are migrated."
