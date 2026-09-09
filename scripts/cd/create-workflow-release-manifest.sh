#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_cmd python
require_env ACR_NAME
require_env GITHUB_SHA

SHORT_SHA="${GITHUB_SHA:0:12}"
SHA_TAG="sha-${SHORT_SHA}"
ACR_LOGIN_SERVER="${ACR_LOGIN_SERVER:-$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)}"
OUT="${RELEASE_MANIFEST_JSON:-$ROOT/release-manifest.json}"

entries=(
  "storefront|cloudmart/storefront"
  "web-bff|cloudmart/web-bff"
  "catalog-service|cloudmart/catalog-service"
  "cart-service|cloudmart/cart-service"
  "order-service|cloudmart/order-service"
  "inventory-service|cloudmart/inventory-service"
  "payment-service|cloudmart/payment-service"
  "notification-service|cloudmart/notification-service"
)

tmp="$(mktemp)"
printf '{}\n' > "$tmp"

for item in "${entries[@]}"; do
  IFS='|' read -r key repository <<<"$item"

  digest="$(
    az acr repository show \
      --name "$ACR_NAME" \
      --image "${repository}:${SHA_TAG}" \
      --query digest \
      -o tsv
  )"

  [[ "$digest" == sha256:* ]] || fail "${repository}:${SHA_TAG} has no immutable digest"

  immutable="${ACR_LOGIN_SERVER}/${repository}@${digest}"

  python - "$tmp" "$key" "$repository" "$digest" "$immutable" <<'PY'
import json, sys
path, key, repository, digest, immutable = sys.argv[1:]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
data[key] = {
    "repository": repository,
    "digest": digest,
    "immutableReference": immutable,
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
PY

  pass "${key} digest captured"
done

export SHA_TAG SHORT_SHA ACR_LOGIN_SERVER
python - "$tmp" "$OUT" <<'PY'
import json, os, sys
src, out = sys.argv[1:]
with open(src, encoding="utf-8") as f:
    images = json.load(f)
payload = {
    "version": os.environ["SHA_TAG"],
    "gitSha": os.environ.get("GITHUB_SHA", ""),
    "tag": os.environ["SHA_TAG"],
    "registry": os.environ["ACR_LOGIN_SERVER"],
    "images": images,
}
with open(out, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")
PY

rm -f "$tmp"
pass "release manifest created: ${OUT}"
