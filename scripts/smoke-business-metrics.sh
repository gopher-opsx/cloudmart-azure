#!/usr/bin/env sh
set -eu

required="cloudmart_orders_created_total cloudmart_orders_confirmed_total cloudmart_orders_cancelled_total cloudmart_payments_authorized_total cloudmart_payments_failed_total cloudmart_inventory_reserved_total cloudmart_inventory_released_total cloudmart_notifications_delivered_total"

for metric in $required; do
  response=$(curl -fsS --get --data-urlencode "query=$metric" http://localhost:9090/api/v1/query)
  echo "$response" | grep -q '"result":\[' || { echo "Prometheus query failed for $metric"; exit 1; }
done

echo "CloudMart business metrics are queryable"
