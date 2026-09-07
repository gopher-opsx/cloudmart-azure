#!/usr/bin/env bash
set -euo pipefail
TARGET="platform/terraform/environments/training/troubleshooting.auto.tfvars"
mkdir -p "$(dirname "$TARGET")"
cat > "$TARGET" <<'EOF'
troubleshooting_order_image = "cloudmart/order-service:troubleshooting-missing"
EOF
printf 'Created %s\nRun terraform plan/apply to inject the failed-image exercise.\n' "$TARGET"
