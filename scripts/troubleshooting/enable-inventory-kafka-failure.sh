#!/usr/bin/env bash
# Purpose: Enables the controlled Inventory Event Hubs/Kafka authentication failure.
# Workflow: Writes a temporary Terraform override that switches Inventory to the intentionally invalid Key Vault credential.

set -euo pipefail

TARGET="platform/terraform/environments/training/troubleshooting.auto.tfvars"

cat > "${TARGET}" <<'EOF'
troubleshooting_inventory_kafka_failure = true
EOF

printf 'Created %s\n' "${TARGET}"
printf 'Lesson 80: Inventory will receive an intentionally invalid Event Hubs SAS credential through Key Vault.\n'
