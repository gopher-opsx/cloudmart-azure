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

1. `make ci-local` validates Go services, the Angular application, and Compose configuration.
2. `make compose-local-up` and `make compose-local-smoke` validate both local Saga outcomes.
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

## Recording gates

Before recording, verify the actual Git repository—not an exported ZIP—contains
the published local-baseline tag and the intended Azure course branch/history.
Also complete one live Azure rehearsal because subscription capacity, regional
SKU availability, Azure CLI behavior, RBAC propagation, and provisioning time
cannot be proven by static repository validation.
