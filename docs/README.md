# Development completion plan

The core CloudMart application is complete and verified locally. Azure work begins only after the following release gates pass.

## Completed

- Angular storefront and Web BFF
- Catalog, Cart, Order, Inventory, Payment, and Notification services
- PostgreSQL, Redis, and Kafka persistence
- Successful and compensated Saga paths
- Transactional outboxes and idempotent consumers
- Production multi-stage Docker images
- One-command Compose stack with health ordering
- Automated HTTP/Kafka business smoke test

## Remaining before Azure

1. Observability: structured JSON logs, W3C trace propagation, OpenTelemetry Collector, Prometheus, Grafana, and trace/metric verification.
2. Migration automation: repeatable versioned migration runner for fresh and existing databases.
3. Browser automation: storefront success and cancellation flows using Playwright.
4. Quality gate: all Go tests, Angular tests/build, Compose smoke, contract validation, and image build in one command.
5. Operations: backup/restore notes, reset procedure, troubleshooting, and failure-injection exercises.
6. Release: final architecture diagram, clean Git status, local baseline tag, and release notes.

## Definition of ready for Azure

One command starts the stack; health checks converge; unit, browser, and both Saga tests pass; telemetry connects a browser request to backend work; databases migrate repeatably; documentation matches reality; and the local baseline is tagged.
