#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

for cmd in git terraform az docker curl python; do
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

if [[ -f "$ROOT/platform/terraform/environments/training/troubleshooting.auto.tfvars" ]]; then
  fail "troubleshooting.auto.tfvars is still active; run disable-overrides.sh"
fi
pass "no troubleshooting override active"

info "Fresh release artifacts are created after the Lesson 53 foundation rebuild."
info "Old release-manifest.json and release.auto.tfvars.json are not trusted as clean-rebuild inputs."

pass "FINAL PROJECT PREFLIGHT"
