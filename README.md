# CloudMart Azure

CloudMart is a cloud-native e-commerce reference application used to teach the migration of a verified local microservice system to Microsoft Azure.

The application is implemented and runs end-to-end with an Angular storefront, Go services, PostgreSQL, Redis, Kafka, transactional outboxes, idempotent consumers, Saga compensation, Docker Compose, and automated smoke verification.

## Architecture

```text
Angular Storefront :4200
          |
       Web BFF :8080
      /      |      \
Catalog   Cart     Order
 :8081    :8082     :8083
   |        |         |
Postgres  Redis    Postgres + Kafka
                         |
       Inventory -> Payment -> Order finalization
          :8084       :8085
             \          /
              Kafka events
                   |
          Notification :8086
```

The browser calls only the Web BFF. Inventory, Payment, and Notification are internal event-driven workers.

## Implemented business flows

Successful checkout:

```text
order.created -> inventory.reserved -> payment.authorized
-> order.confirmed -> notification delivered
```

Compensated checkout:

```text
order.created -> inventory.reserved -> payment.failed
-> order.cancelled -> inventory.released -> notification delivered
```

PostgreSQL transactions combine business-state changes, processed-event markers, and outbox writes. Kafka offsets are committed only after successful handling.

## Technology

- Angular 21 storefront served by Nginx
- Go 1.26 services and Web BFF
- PostgreSQL 16 for durable service data
- Redis 8 for shopping carts
- Apache Kafka 4 for asynchronous workflows
- Docker Compose for the complete local platform
- Terraform for progressive Azure infrastructure stages
- Azure Container Apps, PostgreSQL Flexible Server, Azure Managed Redis, Event Hubs, Key Vault, Application Insights, and ACR
- GitHub Actions with workload-identity federation for CI/CD
- OpenAPI and AsyncAPI contract examples

## Quick start

Requirements: Docker Desktop, Git, Make, and a POSIX-compatible shell such as Git Bash.

```bash
make compose-local-up
```

Open `http://localhost:4200`.

Verify both Saga paths:

```bash
make compose-local-smoke
```

Inspect and stop:

```bash
make compose-local-ps
make compose-local-logs
make compose-local-down
```

The first image build downloads dependencies. Later builds reuse Docker layers and are substantially faster.

## Development workflow

Individual services can run in cached Go development containers:

```bash
make catalog-run
make cart-run
make order-run
make inventory-run
make payment-run
make notification-run
make bff-run
make storefront-run
```

Run each long-lived target in a separate terminal. `make app-stop` stops only application containers and leaves infrastructure running.

## Ports

| Component | Port |
|---|---:|
| Storefront | 4200 |
| Web BFF | 8080 |
| Catalog | 8081 |
| Cart | 8082 |
| Order | 8083 |
| Inventory | 8084 |
| Payment | 8085 |
| Notification | 8086 |
| PostgreSQL | 5432 |
| Redis | 6379 |
| Kafka | 9092 |

## Repository structure

- `apps/storefront` — Angular customer experience
- `services` — independently deployable Go services
- `contracts` — HTTP and event contract examples
- `platform` — Docker, database, and local platform configuration
- `scripts` — repeatable operational and smoke-test commands
- `docs` — architecture decisions, Azure operating notes, and recording asset map
- `monitoring` — prepared KQL queries
- `.github/workflows` — independent CI and Azure delivery workflows

## Course execution conventions

Unless a lesson says otherwise:

- Run commands from the repository root.
- On Windows, use Git Bash for the course terminal.
- Use `docker compose` directly; Make is not required.
- Terraform configuration lives under:
  `platform/terraform/environments/training`
- Course helper scripts are already prepared under `scripts/`.
- Run shell helpers with:
  `bash scripts/<path>/<script>.sh`
- Do not commit `terraform.tfvars`, backend configuration, Terraform state,
  generated release files, passwords, connection strings, or other credentials.
- Load sensitive Terraform values only when required and remove them from the
  shell environment after use.
- Long Azure provisioning/deletion waits shown in the course may be shortened
  in the recording; students should allow the command to complete normally.
- If a verification command fails, stop at that lesson and resolve the failure
  before continuing. Later lessons assume the previous checkpoint passed.
