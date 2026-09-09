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

require_env TF_VAR_postgresql_administrator_password
pass "PostgreSQL administrator password is loaded through TF_VAR"

local_tfvars="$ROOT/platform/terraform/environments/training/terraform.tfvars"
[[ -f "$local_tfvars" ]] || fail "missing ignored local terraform.tfvars"
grep -Eq '^[[:space:]]*postgresql_admin_client_ipv4[[:space:]]*=' "$local_tfvars" ||   fail "terraform.tfvars must define postgresql_admin_client_ipv4 for final-project migrations"
pass "PostgreSQL admin client IPv4 configuration present"

if [[ -f "$ROOT/platform/terraform/environments/training/troubleshooting.auto.tfvars" ]]; then
  fail "troubleshooting.auto.tfvars is still active; run disable-overrides.sh"
fi
pass "no troubleshooting override active"

info "Fresh release artifacts are created after the Lesson 53 foundation rebuild."
info "Old release-manifest.json and release.auto.tfvars.json are not trusted as clean-rebuild inputs."

pass "FINAL PROJECT PREFLIGHT"
