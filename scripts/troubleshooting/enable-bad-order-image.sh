#!/usr/bin/env bash
set -euo pipefail

TARGET="platform/terraform/environments/training/troubleshooting.auto.tfvars"

cat > "${TARGET}" <<'EOF'
troubleshooting_order_image = "cloudmart/order-service:troubleshooting-missing"
EOF

printf 'Created %s\n' "${TARGET}"
printf 'Lesson 79: terraform plan/apply will create an intentionally failed Order revision.\n'
