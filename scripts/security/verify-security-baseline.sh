#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${ROOT}/scripts/lib/course-common.sh"

checks=(
  scripts/security/audit-plaintext-config.sh
  scripts/security/audit-managed-identities.sh
  scripts/security/audit-container-app-env.sh
  scripts/security/audit-key-vault-references.sh
  scripts/security/audit-rbac.sh
  scripts/security/audit-container-app-ingress.sh
  scripts/security/audit-transport.sh
)

for check in "${checks[@]}"; do
  info "running ${check}"
  "${ROOT}/${check}"
done

pass "CLOUDMART SECURITY BASELINE"
