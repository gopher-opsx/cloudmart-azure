#!/usr/bin/env bash
set -euo pipefail

: "${AZURE_RESOURCE_GROUP:?set AZURE_RESOURCE_GROUP}"
: "${EVENT_HUBS_NAMESPACE:?set EVENT_HUBS_NAMESPACE}"
: "${KAFKA_BROKERS:?set KAFKA_BROKERS}"
: "${KAFKA_SASL_PASSWORD:?set KAFKA_SASL_PASSWORD}"

KCAT_IMAGE="${KCAT_IMAGE:-edenhill/kcat:1.7.1}"
TOPIC="${KAFKA_TEST_TOPIC:-cloudmart-connectivity-$(date +%s)-$RANDOM}"
GROUP="${KAFKA_TEST_GROUP:-$TOPIC}"
MESSAGE_KEY="connectivity-key"
MESSAGE_VALUE='{"eventId":"connectivity-test-001","eventType":"connectivity.test","source":"kafka-tools-container"}'

# Refuse permanent streams and existing names before arming cleanup.
[[ "$TOPIC" == cloudmart-connectivity-* ]] || { echo "Use a cloudmart-connectivity-* test name" >&2; exit 1; }
existing="$(az eventhubs eventhub list --resource-group "$AZURE_RESOURCE_GROUP" --namespace-name "$EVENT_HUBS_NAMESPACE" --query '[].name' -o tsv)"
while IFS= read -r name; do
  [[ "${name%$'\r'}" != "$TOPIC" ]] || { echo "Test Event Hub already exists; choose another name" >&2; exit 1; }
done <<< "$existing"
created=false

cleanup() {
  local result=$?
  trap - EXIT
  [[ "$created" == true ]] || exit "$result"
  echo
  echo "Removing temporary Event Hub: ${TOPIC}"
  az eventhubs eventhub delete \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --namespace-name "${EVENT_HUBS_NAMESPACE}" \
    --name "${TOPIC}" \
    --only-show-errors >/dev/null || {
      echo "FAIL temporary Event Hub cleanup: $TOPIC" >&2
      exit 1
    }
  exit "$result"
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
created=true
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
    -o beginning \
    -c 1 \
    -q \
    -f '%k:%s' \
    -G "${GROUP}" "${TOPIC}"
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
