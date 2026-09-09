#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
TF_DIR="${REPO_ROOT}/platform/terraform/environments/training"
MANIFEST="${TF_DIR}/stages/course-stages.tsv"

usage() {
  echo "Usage: $0 [lesson-number]" >&2
  exit 2
}

TARGET="${1:-}"
if [[ -n "${TARGET}" && ! "${TARGET}" =~ ^[0-9]+$ ]]; then
  usage
fi

CURRENT=""
if terraform -chdir="${TF_DIR}" output -raw course_stage >/dev/null 2>&1; then
  CURRENT="$(terraform -chdir="${TF_DIR}" output -raw course_stage 2>/dev/null || true)"
fi

echo "CloudMart Terraform course stage"
echo "--------------------------------"
if [[ -n "${CURRENT}" ]]; then
  echo "Applied state stage : Lesson ${CURRENT}"
else
  echo "Applied state stage : none yet"
fi

if [[ -n "${TARGET}" ]]; then
  STAGE_FILE="${TF_DIR}/stages/lesson-$(printf '%03d' "${TARGET}").tfvars"
  [[ -f "${STAGE_FILE}" ]] || {
    echo "Stage file not found: ${STAGE_FILE}" >&2
    exit 1
  }

  echo "Target lesson       : Lesson ${TARGET}"
  echo
  echo "Capabilities active by this lesson:"
  awk -F '\t' -v target="${TARGET}" '
    NR > 1 && $1 <= target {
      printf "  %-3s  %s\n", $1, $2
    }
  ' "${MANIFEST}"
else
  echo
  echo "Pass a lesson number to preview its active capabilities."
fi
