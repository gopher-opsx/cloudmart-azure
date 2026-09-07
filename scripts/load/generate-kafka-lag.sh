#!/usr/bin/env bash
set -euo pipefail
: "${KAFKA_BROKERS:?set KAFKA_BROKERS}"
: "${KAFKA_SASL_PASSWORD:?set KAFKA_SASL_PASSWORD}"
TOPIC="${KAFKA_TOPIC:-orders}"
COUNT="${EVENT_COUNT:-300}"
command -v kcat >/dev/null || { echo 'kcat is required' >&2; exit 2; }
for i in $(seq 1 "$COUNT"); do
  printf '{"id":"load-%s-%s","type":"order.created","data":{"orderId":"load-%s"}}\n' "$(date +%s)" "$i" "$i"
done | kcat -P -b "$KAFKA_BROKERS" -t "$TOPIC" -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN -X sasl.username='$ConnectionString' -X "sasl.password=$KAFKA_SASL_PASSWORD"
printf 'PASS published %s events to %s\n' "$COUNT" "$TOPIC"
