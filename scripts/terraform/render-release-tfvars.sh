#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="${RELEASE_MANIFEST_JSON:-${ROOT}/release-manifest.json}"
OUT="${ROOT}/platform/terraform/environments/training/release.auto.tfvars.json"

[[ -f "${MANIFEST}" ]] || {
  echo "Release manifest not found: ${MANIFEST}" >&2
  echo "Create it during Section 5 with scripts/record-cloudmart-image-digests.sh." >&2
  exit 1
}

python - "${MANIFEST}" "${OUT}" <<'PY'
import json
import re
import sys

src, out = sys.argv[1:]
with open(src, encoding="utf-8") as f:
    payload = json.load(f)

required = [
    "storefront",
    "web-bff",
    "catalog-service",
    "cart-service",
    "order-service",
    "inventory-service",
    "payment-service",
    "notification-service",
]

images = payload.get("images", {})
missing = [name for name in required if name not in images]
if missing:
    raise SystemExit("release manifest missing: " + ", ".join(missing))

result = {}
for name in required:
    ref = images[name].get("immutableReference", "")
    if not re.search(r"@sha256:[0-9a-fA-F]{64}$", ref):
        raise SystemExit(f"{name}: immutableReference is not a sha256 digest reference")
    result[name] = ref

with open(out, "w", encoding="utf-8") as f:
    json.dump({"cloudmart_image_references": result}, f, indent=2)
    f.write("\n")

print(out)
PY

echo "PASS immutable image Terraform inputs generated"
