#!/usr/bin/env bash
set -euo pipefail

TARGET="platform/terraform/environments/training/troubleshooting.auto.tfvars"

cat > "${TARGET}" <<'EOF'
troubleshooting_inventory_kafka_failure = true
EOF

printf 'Created %s\n' "${TARGET}"
printf 'Lesson 80: Inventory will receive an intentionally invalid Event Hubs SAS credential through Key Vault.\n'
