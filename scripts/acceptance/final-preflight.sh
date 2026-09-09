#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

for cmd in git terraform az docker curl; do
  require_cmd "$cmd"
done

cd "$ROOT"

[[ -z "$(git status --porcelain)" ]] || fail "repository working tree is not clean"
pass "Git working tree clean"

branch="$(git branch --show-current)"
sha="$(git rev-parse --short=12 HEAD)"
pass "Git ${branch}@${sha}"

az account show >/dev/null
subscription="$(az account show --query name -o tsv)"
pass "Azure CLI session: ${subscription}"

backend="$ROOT/platform/terraform/environments/training/training.azurerm.tfbackend"
[[ -f "$backend" ]] || fail "missing local backend configuration: ${backend}"
pass "Terraform backend configuration present"

tfvars="$ROOT/platform/terraform/environments/training/release.auto.tfvars.json"
[[ -f "$tfvars" ]] || fail "missing release.auto.tfvars.json; run scripts/terraform/render-release-tfvars.sh"
pass "immutable Terraform release inputs present"

manifest="$ROOT/release-manifest.json"
[[ -f "$manifest" ]] || fail "release-manifest.json not found"
pass "immutable release manifest present"

if [[ -f "$ROOT/platform/terraform/environments/training/troubleshooting.auto.tfvars" ]]; then
  fail "troubleshooting.auto.tfvars is still active; run disable-overrides.sh"
fi
pass "no troubleshooting override active"

pass "FINAL PROJECT PREFLIGHT"
