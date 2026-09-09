#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

VERIFY="$ROOT/scripts/acceptance/verify-final-system.sh"
[[ -x "$VERIFY" ]] || fail "final acceptance helper missing or not executable: $VERIFY"

"$VERIFY"

pass "FINAL PROJECT POST-PROVISION VERIFICATION"
