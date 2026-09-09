#!/usr/bin/env bash
set -euo pipefail

: "${AZURE_RESOURCE_GROUP:?set AZURE_RESOURCE_GROUP}"
: "${EVENT_HUBS_NAMESPACE:?set EVENT_HUBS_NAMESPACE}"
: "${KAFKA_BROKERS:?set KAFKA_BROKERS}"
: "${KAFKA_SASL_PASSWORD:?set KAFKA_SASL_PASSWORD}"

KCAT_IMAGE="${KCAT_IMAGE:-edenhill/kcat:1.7.1}"
TOPIC="${KAFKA_TEST_TOPIC:-cloudmart-connectivity-test}"
GROUP="${KAFKA_TEST_GROUP:-cloudmart-connectivity-test}"
MESSAGE_KEY="connectivity-key"
MESSAGE_VALUE='{"eventId":"connectivity-test-001","eventType":"connectivity.test","source":"kafka-tools-container"}'

cleanup() {
  echo
  echo "Removing temporary Event Hub: ${TOPIC}"
  az eventhubs eventhub delete \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --namespace-name "${EVENT_HUBS_NAMESPACE}" \
    --name "${TOPIC}" \
    --only-show-errors >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Creating temporary Event Hub: ${TOPIC}"
az eventhubs eventhub create \
  --resource-group "${AZURE_RESOURCE_GROUP}" \
  --namespace-name "${EVENT_HUBS_NAMESPACE}" \
  --name "${TOPIC}" \
  --partition-count 1 \
  --retention-time-in-hours 1 \
  --cleanup-policy Delete \
  --only-show-errors >/dev/null
echo "PASS temporary Event Hub created"

docker_kcat() {
  MSYS_NO_PATHCONV=1 docker run --rm -i \
    "${KCAT_IMAGE}" "$@"
}

common=(
  -b "${KAFKA_BROKERS}"
  -X security.protocol=SASL_SSL
  -X sasl.mechanisms=PLAIN
  -X 'sasl.username=$ConnectionString'
  -X "sasl.password=${KAFKA_SASL_PASSWORD}"
)

echo "Checking Kafka metadata..."
docker_kcat "${common[@]}" -L -t "${TOPIC}" >/dev/null
echo "PASS Kafka metadata"

echo "Producing keyed event..."
printf '%s:%s\n' "${MESSAGE_KEY}" "${MESSAGE_VALUE}" |
  docker_kcat "${common[@]}" \
    -P \
    -t "${TOPIC}" \
    -K :
echo "PASS produce"

echo "Consuming event..."
received="$(
  docker_kcat "${common[@]}" \
    -C \
    -t "${TOPIC}" \
    -G "${GROUP}" \
    -o beginning \
    -c 1 \
    -q \
    -f '%k:%s' 2>/dev/null || true
)"

expected="${MESSAGE_KEY}:${MESSAGE_VALUE}"
if [[ "${received}" != "${expected}" ]]; then
  echo "Kafka round trip failed." >&2
  echo "Expected: ${expected}" >&2
  echo "Received: ${received}" >&2
  exit 1
fi

echo "PASS consume"
echo
echo "Consumed:"
echo "${received}"
echo
echo "PASS Event Hubs Kafka round trip"
