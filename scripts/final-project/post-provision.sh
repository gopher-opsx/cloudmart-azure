#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

VERIFY="$ROOT/scripts/acceptance/verify-final-system.sh"
[[ -f "$VERIFY" ]] || fail "final acceptance helper missing: $VERIFY"

bash "$VERIFY"

pass "FINAL PROJECT POST-PROVISION VERIFICATION"
