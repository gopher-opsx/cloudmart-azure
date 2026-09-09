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
PLAN_FILE="${PLAN_DIR}/lesson-${PADDED}.tfplan"

[[ -f "${PLAN_FILE}" ]] || {
  echo "Saved plan not found: ${PLAN_FILE}" >&2
  echo "Run first: ./scripts/terraform/course-plan.sh ${LESSON}" >&2
  exit 1
}

CURRENT=""
if terraform -chdir="${TF_DIR}" output -raw course_stage >/dev/null 2>&1; then
  CURRENT="$(terraform -chdir="${TF_DIR}" output -raw course_stage 2>/dev/null || true)"
fi

if [[ -n "${CURRENT}" && "${CURRENT}" =~ ^[0-9]+$ ]] && (( LESSON < CURRENT )); then
  if [[ "${ALLOW_STAGE_ROLLBACK:-0}" != "1" ]]; then
    echo "Refusing to apply a backward course stage." >&2
    echo "Applied state : Lesson ${CURRENT}" >&2
    echo "Requested     : Lesson ${LESSON}" >&2
    exit 1
  fi
fi

echo "Applying saved plan for Lesson ${LESSON}..."
terraform -chdir="${TF_DIR}" apply "${PLAN_FILE}"

APPLIED="$(terraform -chdir="${TF_DIR}" output -raw course_stage 2>/dev/null || true)"
if [[ "${APPLIED}" != "${LESSON}" ]]; then
  echo "Stage verification failed after apply." >&2
  echo "Expected Lesson ${LESSON}; Terraform state reports '${APPLIED}'." >&2
  exit 1
fi

echo
echo "Applied course stage verified: Lesson ${APPLIED}"
