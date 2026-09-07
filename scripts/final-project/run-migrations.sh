#!/usr/bin/env bash
set -euo pipefail
: "${PGHOST:?set PGHOST}"
: "${PGUSER:?set PGUSER}"
: "${PGPASSWORD:?set PGPASSWORD}"
command -v psql >/dev/null || { echo 'psql is required' >&2; exit 2; }
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
declare -A dirs=(
  [catalog_db]="services/catalog-service/migrations"
  [orders_db]="services/order-service/migrations"
  [inventory_db]="services/inventory-service/migrations"
  [payments_db]="services/payment-service/migrations"
  [notifications_db]="services/notification-service/migrations"
)
for db in catalog_db orders_db inventory_db payments_db notifications_db; do
  echo "INFO migrating $db"
  for file in "$ROOT/${dirs[$db]}"/*.sql; do
    [[ -f "$file" ]] || continue
    psql "sslmode=require dbname=$db" -v ON_ERROR_STOP=1 -f "$file"
  done
  echo "PASS $db migrations"
done
