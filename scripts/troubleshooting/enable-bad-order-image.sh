#!/usr/bin/env bash
# Purpose: Enables the controlled bad-image scenario used to troubleshoot a failed Order revision.
# Workflow: Writes a temporary Terraform override that points Order at an intentionally invalid image reference.

set -euo pipefail

TARGET="platform/terraform/environments/training/troubleshooting.auto.tfvars"

cat > "${TARGET}" <<'EOF'
troubleshooting_order_image = "cloudmart/order-service:troubleshooting-missing"
EOF

printf 'Created %s\n' "${TARGET}"
printf 'Lesson 79: terraform plan/apply will create an intentionally failed Order revision.\n'
