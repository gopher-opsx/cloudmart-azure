#!/usr/bin/env bash
set -euo pipefail

TARGET="platform/terraform/environments/training/troubleshooting.auto.tfvars"

cat > "${TARGET}" <<'EOF'
troubleshooting_catalog_db_failure = true
EOF

printf 'Created %s\n' "${TARGET}"
printf 'Lesson 80: Catalog will receive a Key Vault referenced URL with an intentionally unreachable PostgreSQL port.\n'
