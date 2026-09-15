#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_cmd git
require_cmd terraform

VERSION="${1:-1.0.0}"

git_status="$(git -C "$ROOT" status --short)"

[[ -z "$git_status" ]] \
  || fail "Git working tree must be clean before preparing release metadata"

TF_ROOT="$ROOT/platform/terraform/environments/training"
OUT="$ROOT/platform/images/release.env"

ACR_NAME="$(
  terraform -chdir="$TF_ROOT" \
    output -raw container_registry_name
)"

[[ -n "$ACR_NAME" && "$ACR_NAME" != "null" ]] \
  || fail "Container Registry is not available"

ACR_LOGIN_SERVER="$(
  az acr show \
    --name "$ACR_NAME" \
    --query loginServer \
    -o tsv
)"

GIT_SHA="$(
  git -C "$ROOT" rev-parse HEAD
)"

SHA_TAG="sha-${GIT_SHA:0:12}"

mkdir -p "$(dirname "$OUT")"

cat > "$OUT" <<EOF
ACR_NAME="${ACR_NAME}"
CLOUDMART_ACR_LOGIN_SERVER="${ACR_LOGIN_SERVER}"
CLOUDMART_IMAGE_VERSION="${VERSION}"
CLOUDMART_GIT_SHA="${GIT_SHA}"
CLOUDMART_SHA_TAG="${SHA_TAG}"
EOF

pass "CloudMart image release metadata prepared"

printf '\n'
cat "$OUT"
