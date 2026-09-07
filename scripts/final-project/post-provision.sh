#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

steps=(
  scripts/final-project/run-migrations.sh
  scripts/cd/deploy-container-apps.sh
  scripts/cd/verify-release.sh
)
for step in "${steps[@]}"; do
  [[ -x "$ROOT/$step" ]] || fail "required final-project helper missing/executable bit absent: $step"
done
require_env PGHOST
require_env PGUSER
require_env PGPASSWORD
require_env ACR_LOGIN_SERVER
MANIFEST="${RELEASE_MANIFEST:-release-manifest.json}"
[[ -f "$MANIFEST" ]] || fail "RELEASE_MANIFEST not found: $MANIFEST"
"$ROOT/scripts/final-project/run-migrations.sh"
"$ROOT/scripts/cd/deploy-container-apps.sh" "$MANIFEST"
"$ROOT/scripts/cd/verify-release.sh"
pass "final-project post-provision workflow"
