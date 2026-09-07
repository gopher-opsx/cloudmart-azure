#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd git
cd "$ROOT"

tracked="$(git ls-files)"
printf '%s\n' "$tracked" | grep -Eq '(^|/)terraform\.tfstate(\.|$)|(^|/)terraform\.tfvars$|\.tfbackend$|(^|/)config\.json$' && fail "tracked sensitive runtime file detected" || true
pass "no tracked Terraform state/populated tfvars/backend/Docker auth"

# Search for common populated Azure connection-string forms while excluding examples and lock files.
if git grep -nE '(SharedAccessKey=|AccountKey=|redis.*password[[:space:]]*=[[:space:]]*[^<${]|postgres(ql)?://[^:< ]+:[^@<${ ]+@)' -- ':!*.example' ':!*.md' ':!package-lock.json' >/tmp/cloudmart-secret-scan.txt 2>/dev/null; then
  cat /tmp/cloudmart-secret-scan.txt >&2
  fail "possible plaintext credential detected"
fi
pass "no known populated credential patterns in tracked source"
