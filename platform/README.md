# Local Platform

`platform/docker/compose.yaml` defines the full CloudMart environment: PostgreSQL, Redis, Kafka, topic initialization, seven Go containers, Web BFF, and the Nginx storefront.

## Commands

```bash
make compose-local-up
make compose-local-ps
make compose-local-logs
make compose-local-smoke
make compose-local-down
```

Named volumes preserve PostgreSQL and Redis data across ordinary shutdowns. `compose-local-down` does not delete volumes. Never add `--volumes` unless intentionally resetting local data.

Database init scripts run only when PostgreSQL creates a fresh volume. Migrations for existing databases are currently applied explicitly; migration automation is a remaining pre-Azure task.
