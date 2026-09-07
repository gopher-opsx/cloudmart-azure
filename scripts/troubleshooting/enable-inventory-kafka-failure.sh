#!/usr/bin/env bash
set -euo pipefail
TARGET="platform/terraform/environments/training/troubleshooting.auto.tfvars"
cat > "$TARGET" <<'EOF'
troubleshooting_inventory_kafka_secret_name = "event-hubs-connection-string-invalid"
EOF
printf 'Created %s for Inventory Kafka-auth failure exercise.\n' "$TARGET"
