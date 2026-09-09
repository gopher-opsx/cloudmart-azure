#!/usr/bin/env bash
set -euo pipefail

: "${POSTGRESQL_HOST:?set POSTGRESQL_HOST}"
: "${POSTGRESQL_ADMIN:?set POSTGRESQL_ADMIN}"
: "${POSTGRESQL_PASSWORD:?set POSTGRESQL_PASSWORD}"

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

declare -A DATABASES=(
  [catalog-service]="catalog_db"
  [order-service]="orders_db"
  [inventory-service]="inventory_db"
  [payment-service]="payments_db"
  [notification-service]="notifications_db"
)

run_service_migrations() {
  local service_name="$1"
  local database_name="$2"
  local migration_directory="${ROOT}/services/${service_name}/migrations"
  local migration_count=0

  echo
  echo "Migrating ${service_name} -> ${database_name}"

  shopt -s nullglob
  local files=("${migration_directory}"/*.sql)
  shopt -u nullglob

  if (( ${#files[@]} == 0 )); then
    echo "No migrations found for ${service_name}" >&2
    return 1
  fi

  for migration_file in "${files[@]}"; do
    migration_count=$((migration_count + 1))
    echo "Applying $(basename "${migration_file}")"

    MSYS_NO_PATHCONV=1 docker run --rm -i \
      -e PGHOST="${POSTGRESQL_HOST}" \
      -e PGPORT=5432 \
      -e PGDATABASE="${database_name}" \
      -e PGUSER="${POSTGRESQL_ADMIN}" \
      -e PGPASSWORD="${POSTGRESQL_PASSWORD}" \
      -e PGSSLMODE=verify-full \
      -e PGSSLROOTCERT=/etc/ssl/certs/ca-certificates.crt \
      postgres:16-alpine \
      psql \
        --no-password \
        --set=ON_ERROR_STOP=1 \
        --file=- \
      < "${migration_file}"
  done

  echo "PASS ${service_name}: ${migration_count} migration file(s)"
}

for service_name in \
  catalog-service \
  order-service \
  inventory-service \
  payment-service \
  notification-service
do
  run_service_migrations \
    "${service_name}" \
    "${DATABASES[$service_name]}"
done
