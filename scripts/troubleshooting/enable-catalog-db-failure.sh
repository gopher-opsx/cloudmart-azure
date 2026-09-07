#!/usr/bin/env bash
set -euo pipefail
TARGET="platform/terraform/environments/training/troubleshooting.auto.tfvars"
cat > "$TARGET" <<'EOF'
troubleshooting_catalog_database_secret_name = "catalog-database-url-invalid"
EOF
printf 'Created %s for Catalog DB failure exercise.\n' "$TARGET"
