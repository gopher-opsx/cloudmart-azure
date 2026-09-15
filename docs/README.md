# CloudMart course implementation status

The local application and the prepared Azure course implementation are present
in this repository. The course deliberately separates application validation,
progressive Azure infrastructure, workload deployment, security, observability,
delivery automation, final acceptance, and teardown.

## Implemented

- Angular Storefront and Web BFF
- Catalog, Cart, Order, Inventory, Payment, and Notification services
- PostgreSQL, Redis, and Kafka local persistence
- Successful and compensated Saga paths
- Transactional outboxes and idempotent consumers
- OpenTelemetry HTTP tracing and Prometheus-format application metrics
- Production multi-stage Docker images and Docker Compose health ordering
- Repeatable PostgreSQL migration and Azure verification helpers
- Terraform modules and Lesson 22–95 progressive stage files
- Azure Container Apps, ACR, PostgreSQL Flexible Server, Azure Managed Redis,
  Event Hubs, Key Vault, managed identities, RBAC, and observability resources
- Security, troubleshooting, release, acceptance, evidence, and cleanup helpers
- GitHub Actions CI and OIDC-based Azure delivery workflow

## Validation layers

1. `bash scripts/ci/test-cloudmart.sh` validates Go services and the Angular application; `bash scripts/ci/validate-images.sh` validates all eight container images.
2. Direct `docker compose` commands start the local application/observability stack, and `bash scripts/smoke-local.sh` validates both local Saga outcomes.
3. Terraform format, initialization, validation, plan review, apply, and Azure verification are performed at each lesson checkpoint.
4. `scripts/acceptance/verify-final-system.sh` runs the machine-repeatable final Azure acceptance gate.
5. Lessons 90–92 add browser, Saga, telemetry, security, and sanitized evidence checks.
6. Lessons 94–95 destroy and verify both the workload and the separately managed Terraform-state bootstrap.

## Important observability boundary

The Go HTTP services emit OpenTelemetry HTTP spans, and synchronous BFF-to-service
calls propagate W3C trace context. The asynchronous Saga is correlated across
Inventory, Payment, Order, and Notification by its Order ID and event IDs in
logs and durable database records. The prepared application does not claim one
continuous OpenTelemetry span tree across Kafka/Event Hubs consumers.

## Lab readiness gates

Before running the Azure labs, verify the actual Git repository—not an exported ZIP—contains the intended course history and required release assets. Complete one live Azure rehearsal before publishing the course because subscription capacity, regional SKU availability, Azure CLI behavior, RBAC propagation, and provisioning time cannot be proven by static repository validation.
## Bash helper reference

See [`BASH-SCRIPT-REFERENCE.md`](BASH-SCRIPT-REFERENCE.md) for a concise explanation of every course Bash helper and the reusable automation patterns inside them.

