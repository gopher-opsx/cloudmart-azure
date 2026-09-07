#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"
require_cmd az
require_cmd git
require_cmd python
if [[ -f "$ROOT/platform/images/release.env" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT/platform/images/release.env"
fi
require_env ACR_NAME

SHORT_SHA="$(git -C "$ROOT" rev-parse --short=12 HEAD)"
FULL_SHA="$(git -C "$ROOT" rev-parse HEAD)"
SHA_TAG="sha-${SHORT_SHA}"
VERSION_TAG="${RELEASE_VERSION:-1.0.0}"
OUT_MD="$ROOT/platform/images/release-manifest.md"
OUT_JSON="${RELEASE_MANIFEST_JSON:-$ROOT/release-manifest.json}"
mkdir -p "$(dirname "$OUT_MD")"
cat > "$OUT_MD" <<EOF
# CloudMart Release Manifest

- Git SHA: \`$FULL_SHA\`
- SHA tag: \`$SHA_TAG\`
- Version tag: \`$VERSION_TAG\`

| Component | Repository | Digest |
|---|---|---|
EOF

tmp="$(mktemp)"
printf '{}\n' > "$tmp"
entries=(
  "storefront|cloudmart/storefront"
  "web-bff|cloudmart/web-bff"
  "catalog|cloudmart/catalog-service"
  "cart|cloudmart/cart-service"
  "order|cloudmart/order-service"
  "inventory|cloudmart/inventory-service"
  "payment|cloudmart/payment-service"
  "notification|cloudmart/notification-service"
)
for item in "${entries[@]}"; do
  IFS='|' read -r key repo <<<"$item"
  sha_digest="$(az acr repository show --name "$ACR_NAME" --image "$repo:$SHA_TAG" --query digest -o tsv)"
  version_digest="$(az acr repository show --name "$ACR_NAME" --image "$repo:$VERSION_TAG" --query digest -o tsv)"
  [[ -n "$sha_digest" ]] || fail "$repo:$SHA_TAG has no digest"
  [[ "$sha_digest" == "$version_digest" ]] || fail "$repo tags resolve to different digests"
  printf '| %s | `%s` | `%s` |\n' "$key" "$repo" "$sha_digest" >> "$OUT_MD"
  python - "$tmp" "$key" "$repo" "$sha_digest" <<'PY2'
import json,sys
path,key,repo,digest=sys.argv[1:]
data=json.load(open(path))
data[key]={"repository":repo,"digest":digest}
json.dump(data,open(path,'w'),indent=2)
PY2
  pass "$key digest recorded"
done
python - "$tmp" "$OUT_JSON" "$FULL_SHA" "$SHA_TAG" <<'PY2'
import json,sys
src,out,sha,tag=sys.argv[1:]
images=json.load(open(src))
json.dump({"gitSha":sha,"tag":tag,"images":images},open(out,'w'),indent=2)
PY2
rm -f "$tmp"
info "wrote $OUT_MD"
info "wrote $OUT_JSON"
