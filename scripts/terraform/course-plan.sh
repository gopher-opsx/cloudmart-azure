#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
TF_DIR="${REPO_ROOT}/platform/terraform/environments/training"
PLAN_DIR="${REPO_ROOT}/.course/terraform-plans"

usage() {
  echo "Usage: $0 <lesson-number>" >&2
  exit 2
}

LESSON="${1:-}"
[[ "${LESSON}" =~ ^[0-9]+$ ]] || usage

if (( LESSON < 22 || LESSON > 95 )); then
  echo "Lesson must be between 22 and 95." >&2
  exit 2
fi

PADDED="$(printf '%03d' "${LESSON}")"
STAGE_FILE="stages/lesson-${PADDED}.tfvars"
FULL_STAGE_FILE="${TF_DIR}/${STAGE_FILE}"
PLAN_FILE="${PLAN_DIR}/lesson-${PADDED}.tfplan"

[[ -f "${FULL_STAGE_FILE}" ]] || {
  echo "Missing course stage file: ${FULL_STAGE_FILE}" >&2
  exit 1
}

CURRENT=""
if terraform -chdir="${TF_DIR}" output -raw course_stage >/dev/null 2>&1; then
  CURRENT="$(terraform -chdir="${TF_DIR}" output -raw course_stage 2>/dev/null || true)"
fi

if [[ -n "${CURRENT}" && "${CURRENT}" =~ ^[0-9]+$ ]] && (( LESSON < CURRENT )); then
  if [[ "${ALLOW_STAGE_ROLLBACK:-0}" != "1" ]]; then
    echo "Refusing backward course stage." >&2
    echo "Applied state : Lesson ${CURRENT}" >&2
    echo "Requested     : Lesson ${LESSON}" >&2
    echo >&2
    echo "A backward stage may propose destroying later course resources." >&2
    echo "Set ALLOW_STAGE_ROLLBACK=1 only when that destruction is intentional." >&2
    exit 1
  fi
fi

"${SCRIPT_DIR}/course-stage.sh" "${LESSON}"
echo

mkdir -p "${PLAN_DIR}"

echo "Validating Terraform..."
terraform -chdir="${TF_DIR}" validate

echo
echo "Planning Lesson ${LESSON}..."
terraform -chdir="${TF_DIR}" plan \
  -var-file="${STAGE_FILE}" \
  -out="${PLAN_FILE}"

echo
echo "Saved plan:"
echo "  ${PLAN_FILE}"
