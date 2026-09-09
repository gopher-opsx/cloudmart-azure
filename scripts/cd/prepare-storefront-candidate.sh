#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/course-common.sh"

require_cmd az
require_cmd jq

MANIFEST="${1:-release-manifest.json}"
[[ -f "$MANIFEST" ]] || fail "release manifest not found: $MANIFEST"

RG="$(cloudmart_rg)"
APP="${APP_NAME:-ca-storefront-training}"

image="$(jq -r '.images.storefront.immutableReference' "$MANIFEST")"
git_sha="$(jq -r '.gitSha' "$MANIFEST")"
[[ "$image" == *@sha256:* ]] || fail "Storefront immutable image missing"
[[ -n "$git_sha" && "$git_sha" != null ]] || fail "manifest gitSha missing"

suffix="sha-$(cut -c1-12 <<<"$git_sha")"
candidate="${APP}--${suffix}"

current_mode="$(
  az containerapp show \
    --resource-group "$RG" \
    --name "$APP" \
    --query properties.configuration.activeRevisionsMode \
    -o tsv
)"

if [[ "$current_mode" != "Multiple" ]]; then
  info "Switching Storefront operational revision mode to Multiple for the release exercise"
  az containerapp revision set-mode \
    --resource-group "$RG" \
    --name "$APP" \
    --mode multiple \
    --only-show-errors >/dev/null
else
  info "Storefront already uses Multiple revision mode"
fi

traffic="$(az containerapp ingress traffic show -g "$RG" -n "$APP" -o json)"
stable="$(
  jq -r '
    map(select((.weight // 0) > 0 and (.revisionName // "") != ""))
    | sort_by(.weight)
    | last
    | .revisionName // empty
  ' <<<"$traffic"
)"

[[ -n "$stable" ]] || fail "could not determine current stable Storefront revision"

az containerapp revision label add \
  --resource-group "$RG" \
  --name "$APP" \
  --revision "$stable" \
  --label stable \
  --only-show-errors >/dev/null

az containerapp revision copy \
  --resource-group "$RG" \
  --name "$APP" \
  --image "$image" \
  --revision-suffix "$suffix" \
  --only-show-errors >/dev/null

az containerapp revision label add \
  --resource-group "$RG" \
  --name "$APP" \
  --revision "$candidate" \
  --label candidate \
  --only-show-errors >/dev/null

az containerapp ingress traffic set \
  --resource-group "$RG" \
  --name "$APP" \
  --revision-weight "${stable}=100" "${candidate}=0" \
  --only-show-errors >/dev/null

main_fqdn="$(
  az containerapp show \
    --resource-group "$RG" \
    --name "$APP" \
    --query properties.configuration.ingress.fqdn \
    -o tsv
)"
suffix_fqdn="${main_fqdn#${APP}.}"
candidate_fqdn="${APP}---candidate.${suffix_fqdn}"

cat <<EOF
STABLE_REVISION=${stable}
CANDIDATE_REVISION=${candidate}
CANDIDATE_URL=https://${candidate_fqdn}
EOF

pass "candidate created with 0% production traffic"
