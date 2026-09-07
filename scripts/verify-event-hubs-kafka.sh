#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd kcat
require_env KAFKA_BROKERS
require_env KAFKA_SASL_PASSWORD
TOPIC="${KAFKA_TEST_TOPIC:-cloudmart-connectivity-test}"
GROUP="${KAFKA_TEST_GROUP:-cloudmart-connectivity-test}"
MSG="cloudmart-kafka-test-$(date +%s)"

common=(-b "$KAFKA_BROKERS" -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN -X sasl.username='$ConnectionString' -X "sasl.password=$KAFKA_SASL_PASSWORD")
printf '%s\n' "$MSG" | kcat "${common[@]}" -P -t "$TOPIC"
received="$(timeout 20 kcat "${common[@]}" -C -t "$TOPIC" -G "$GROUP" -o end -c 1 2>/dev/null || true)"
[[ "$received" == *"$MSG"* ]] || fail "Kafka round trip failed"
pass "Event Hubs Kafka round trip"
