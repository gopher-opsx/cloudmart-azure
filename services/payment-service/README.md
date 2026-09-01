# Payment Service

Kafka worker that simulates payment authorization and stores results in PostgreSQL `payments_db`.

Consumes `inventory.reserved` from `inventory`. Produces `payment.authorized` or `payment.failed` to `payments` through a transactional outbox. Processed event IDs provide idempotency.

## Training rule

Orders with totals at or below `PAYMENT_MAX_AUTH_CENTS` authorize. Larger totals fail deterministically, allowing both Saga paths without an external payment provider.

## Configuration

| Variable | Default |
|---|---|
| `HTTP_ADDR` | `:8085` |
| `DATABASE_URL` | local `payments_db` |
| `KAFKA_BROKERS` | `localhost:9092` |
| `INVENTORY_TOPIC` | `inventory` |
| `PAYMENTS_TOPIC` | `payments` |
| `KAFKA_CONSUMER_GROUP` | `payment-service` |
| `PAYMENT_MAX_AUTH_CENTS` | `500000` |

Run with `make payment-run` or as part of `make compose-local-up`.
