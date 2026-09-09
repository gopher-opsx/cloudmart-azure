#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TF_DIR="$ROOT/platform/terraform/environments/training"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd terraform
require_cmd az

RG="$(cloudmart_rg)"
CONFIRM="${CONFIRM_FINAL_PROJECT_RESET:-}"

[[ "$CONFIRM" == "$RG" ]] || {
  echo "Refusing destructive final-project reset." >&2
  echo "Set CONFIRM_FINAL_PROJECT_RESET=${RG} and run again." >&2
  exit 2
}

info "planning destruction of CloudMart workload: ${RG}"

terraform -chdir="$TF_DIR" plan \
  -destroy \
  -var-file=stages/lesson-088.tfvars \
  -out=cloudmart-final-reset.tfplan

terraform -chdir="$TF_DIR" apply cloudmart-final-reset.tfplan

"$ROOT/scripts/acceptance/verify-workload-destroyed.sh"

pass "FINAL PROJECT CLEAN CHECKPOINT READY"
