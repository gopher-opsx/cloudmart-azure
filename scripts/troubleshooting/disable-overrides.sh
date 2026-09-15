#!/usr/bin/env bash
# Purpose: Removes temporary Terraform troubleshooting overrides and returns the course configuration to normal.
# Workflow: Deletes the controlled-failure tfvars file so the next plan restores the intended source of truth.

set -euo pipefail
rm -f platform/terraform/environments/training/troubleshooting.auto.tfvars
printf 'PASS troubleshooting override removed\n'
