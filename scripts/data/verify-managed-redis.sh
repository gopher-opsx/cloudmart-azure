#!/usr/bin/env bash
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
