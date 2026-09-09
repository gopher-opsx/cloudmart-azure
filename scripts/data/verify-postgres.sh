#!/usr/bin/env bash
set -euo pipefail

: "${POSTGRESQL_HOST:?set POSTGRESQL_HOST}"
: "${POSTGRESQL_ADMIN:?set POSTGRESQL_ADMIN}"
: "${POSTGRESQL_PASSWORD:?set POSTGRESQL_PASSWORD}"

DATABASES=(
  catalog_db
  orders_db
  inventory_db
  payments_db
  notifications_db
)

for database_name in "${DATABASES[@]}"; do
  echo
  echo "=== ${database_name} ==="

  MSYS_NO_PATHCONV=1 docker run --rm \
    -e PGHOST="${POSTGRESQL_HOST}" \
    -e PGPORT=5432 \
    -e PGDATABASE="${database_name}" \
    -e PGUSER="${POSTGRESQL_ADMIN}" \
    -e PGPASSWORD="${POSTGRESQL_PASSWORD}" \
    -e PGSSLMODE=verify-full \
    -e PGSSLROOTCERT=/etc/ssl/certs/ca-certificates.crt \
    postgres:16-alpine \
    psql --no-password --tuples-only --command="
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ORDER BY table_name;
    "
done
