#!/usr/bin/env bash
set -euo pipefail
URL="${1:-${STOREFRONT_URL:-}}"
[[ -n "$URL" ]] || { echo "usage: $0 https://storefront-fqdn" >&2; exit 2; }
REQUESTS="${REQUESTS:-500}"
CONCURRENCY="${CONCURRENCY:-25}"
printf 'Generating %s requests with concurrency %s against %s\n' "$REQUESTS" "$CONCURRENCY" "$URL"
seq "$REQUESTS" | xargs -P "$CONCURRENCY" -I{} curl -fsS -o /dev/null "${URL%/}/api/products"
printf 'PASS HTTP load completed\n'
