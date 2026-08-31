# Payment Service

CloudMart Payment Service is an event-driven worker.

It consumes `inventory.reserved` from Kafka, simulates authorization, persists the result in PostgreSQL, records processed event IDs for idempotency, and writes an outgoing event to a transactional outbox.

It emits `payment.authorized` or `payment.failed` to the `payments` Kafka topic.

Local defaults:
- HTTP: `:8085`
- PostgreSQL: `payments_db`
- Kafka: `localhost:9092`
- Consumer topic: `inventory`
- Consumer group: `payment-service`
- Producer topic: `payments`
- Authorization ceiling: `500000` cents

Simulation rule: authorize when total <= PAYMENT_MAX_AUTH_CENTS, otherwise fail.
