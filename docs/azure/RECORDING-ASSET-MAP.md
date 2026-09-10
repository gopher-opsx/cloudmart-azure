# CloudMart recording asset map

This file maps the automation-heavy lessons to the repository assets that should be opened or executed during recording.

| Lesson | Asset | Recording use |
|---|---|---|
| 29 | `scripts/build-and-push-cloudmart-images.sh` | Explain one Buildx operation, then run the helper for all eight images. |
| 30 | `scripts/record-cloudmart-image-digests.sh` | Resolve SHA/version tags and write immutable release evidence. |
| 38 | `scripts/verify-platform-foundation.sh` | Consolidated platform-foundation verification. |
| 51 | `scripts/verify-event-hubs-kafka.sh` | Real Kafka producer/consumer round trip. |
| 68 | `scripts/security/audit-managed-identities.sh` | Verify workload identity attachment. |
| 69 | `scripts/security/audit-plaintext-config.sh`, `audit-container-app-env.sh` | Repository/runtime secret boundary. |
| 70 | `scripts/security/audit-rbac.sh` | Check prohibited broad workload roles. |
| 71 | `scripts/security/audit-container-app-ingress.sh` | Verify external/internal/no-ingress matrix. |
| 72 | `scripts/security/verify-security-baseline.sh` | Consolidated security checkpoint. |
| 78 | `scripts/load/generate-http-load.sh`, `generate-kafka-lag.sh` | Controlled scaling stimulus. |
| 79 | `scripts/troubleshooting/enable-bad-order-image.sh` | Inject reversible failed-image exercise. |
| 80 | `enable-catalog-db-failure.sh`, `enable-inventory-kafka-failure.sh`, `disable-overrides.sh` | Inject/restore dependency failures. |
| 83 | `scripts/bootstrap/configure-github-oidc.sh` | Create Entra app/SP + federated credential; role assignment remains explicit after resources exist. |
| 86 | `scripts/cd/deploy-container-apps.sh`, `verify-release.sh` | Digest-based revision deployment and verification. |
| 87 | `scripts/cd/smoke-test.sh` | Bounded post-deployment functional gate. |
| 88 | `candidate-verify.sh`, `set-storefront-traffic.sh` | Candidate verification and weighted rollout/rollback. |
| 89 | `scripts/final-project/post-provision.sh` | Rebuild orchestration after Terraform apply. |
| 90 | `scripts/acceptance/verify-final-system.sh` | Consolidated final application/platform acceptance. |
| 92 | `scripts/acceptance/capture-final-evidence.sh` | Sanitized final evidence capture. |
| 94 | `scripts/acceptance/verify-workload-destroyed.sh` | Verify the Terraform-managed workload is gone while state remains available. |
| 95 | `scripts/bootstrap/destroy-tfstate.sh`, `scripts/acceptance/verify-course-cleanup.sh` | Remove the retained state bootstrap, then verify active-resource cleanup. |

## Files intentionally created locally and not committed

- `platform/images/release.env` from `release.env.example`
- `platform/terraform/environments/training/terraform.tfvars` from its example
- `platform/terraform/environments/training/training.azurerm.tfbackend` from its example

Always rehearse destructive and Azure-changing helpers before recording.
