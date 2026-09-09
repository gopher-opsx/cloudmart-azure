# CloudMart GitHub Actions delivery

The training delivery workflow is intentionally manual:

```text
.github/workflows/deploy-training.yml
```

It uses the GitHub `training` environment and supports these recording stages:

| Operation | Purpose |
|---|---|
| `identity` | Prove GitHub OIDC login only |
| `build` | Build all eight images without publishing |
| `publish` | Build, push SHA-tagged images, create immutable release manifest |
| `deploy` | Publish, deploy all eight immutable digests, run smoke tests |
| `candidate` | Publish, deploy non-edge apps, create zero-traffic Storefront candidate, verify it, shift 10% traffic |
| `promote` | Route 100% traffic to candidate label |
| `rollback` | Route 100% traffic back to stable label |

Required GitHub environment variables:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
ACR_NAME
RESOURCE_GROUP
```

No Azure client secret or ACR password is stored.

The OIDC bootstrap assigns:

- `AcrPush` at the CloudMart ACR scope
- `Container Apps Contributor` at the training resource-group scope

The release manifest stores immutable `repository@sha256:digest` references.
The deployment helper consumes those exact references.

Storefront release traffic is deliberately owned by CD. Terraform owns the
revision mode and ignores traffic-weight drift so an infrastructure plan does
not undo an operational canary or rollback decision.
