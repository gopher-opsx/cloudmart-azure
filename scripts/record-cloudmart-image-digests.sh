#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_cmd git
require_cmd python

RELEASE_ENV="$ROOT/platform/images/release.env"
[[ -f "$RELEASE_ENV" ]] || fail "missing $RELEASE_ENV (copy release.env.example and populate it first)"
# shellcheck disable=SC1090
source "$RELEASE_ENV"

require_env ACR_NAME
require_env CLOUDMART_ACR_LOGIN_SERVER
require_env CLOUDMART_IMAGE_VERSION
require_env CLOUDMART_GIT_SHA
require_env CLOUDMART_SHA_TAG

export CLOUDMART_IMAGE_VERSION CLOUDMART_GIT_SHA CLOUDMART_SHA_TAG CLOUDMART_ACR_LOGIN_SERVER

CURRENT_SHA="$(git -C "$ROOT" rev-parse HEAD)"
[[ "$CURRENT_SHA" == "$CLOUDMART_GIT_SHA" ]] || \
  fail "release.env Git SHA does not match the current checkout"

OUT_MD="$ROOT/platform/images/release-manifest.md"
OUT_JSON="${RELEASE_MANIFEST_JSON:-$ROOT/release-manifest.json}"
mkdir -p "$(dirname "$OUT_MD")"

cat > "$OUT_MD" <<EOF2
# CloudMart Release ${CLOUDMART_IMAGE_VERSION}

Source revision: \`${CLOUDMART_GIT_SHA}\`

| Component | Version | Git tag | Digest | Immutable image reference |
|---|---|---|---|---|
EOF2

tmp="$(mktemp)"
printf '{}\n' > "$tmp"

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

for item in "${entries[@]}"; do
  IFS='|' read -r key repository <<<"$item"

  version_digest="$(az acr repository show \
    --name "$ACR_NAME" \
    --image "${repository}:${CLOUDMART_IMAGE_VERSION}" \
    --query digest -o tsv)"

  sha_digest="$(az acr repository show \
    --name "$ACR_NAME" \
    --image "${repository}:${CLOUDMART_SHA_TAG}" \
    --query digest -o tsv)"

  [[ -n "$version_digest" ]] || fail "${repository}:${CLOUDMART_IMAGE_VERSION} has no digest"
  [[ "$version_digest" == "$sha_digest" ]] || fail "$repository tags resolve to different digests"

  immutable_ref="${CLOUDMART_ACR_LOGIN_SERVER}/${repository}@${version_digest}"
  printf '| %s | `%s` | `%s` | `%s` | `%s` |\n' \
    "$key" "$CLOUDMART_IMAGE_VERSION" "$CLOUDMART_SHA_TAG" "$version_digest" "$immutable_ref" >> "$OUT_MD"

  python - "$tmp" "$key" "$repository" "$version_digest" "$immutable_ref" <<'PY2'
import json, sys
path, key, repository, digest, immutable_ref = sys.argv[1:]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
data[key] = {
    "repository": repository,
    "digest": digest,
    "immutableReference": immutable_ref,
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
PY2

  pass "$key digest recorded"
done

python - "$tmp" "$OUT_JSON" <<'PY2'
import json, os, sys
src, out = sys.argv[1:]
with open(src, encoding="utf-8") as f:
    images = json.load(f)
payload = {
    "version": os.environ["CLOUDMART_IMAGE_VERSION"],
    "gitSha": os.environ["CLOUDMART_GIT_SHA"],
    "tag": os.environ["CLOUDMART_SHA_TAG"],
    "registry": os.environ["CLOUDMART_ACR_LOGIN_SERVER"],
    "images": images,
}
with open(out, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2)
PY2

rm -f "$tmp"
info "wrote $OUT_MD"
info "wrote $OUT_JSON"
