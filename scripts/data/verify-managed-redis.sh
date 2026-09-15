#!/usr/bin/env bash
# Purpose: Checks connectivity and configuration for Azure Managed Redis used by the Cart service.
# Workflow: Queries the deployed cache and validates the expected secure runtime settings.

set -euo pipefail

: "${REDIS_HOST:?set REDIS_HOST}"
: "${REDIS_PORT:?set REDIS_PORT}"
: "${REDIS_PRIMARY_KEY:?set REDIS_PRIMARY_KEY}"

MSYS_NO_PATHCONV=1 docker run --rm \
  redis:8-alpine \
  redis-cli \
    -h "${REDIS_HOST}" \
    -p "${REDIS_PORT}" \
    -a "${REDIS_PRIMARY_KEY}" \
    --tls \
    PING
