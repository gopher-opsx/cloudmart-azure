# Notification Service

Consumes `order.confirmed` and `order.cancelled` from `orders` with independent group `notification-service-v1`.

Each accepted event is stored exactly once in PostgreSQL `notifications_db`. The service renders a customer email, simulates delivery, and records an append-only delivery attempt.

## Data model

- `notifications` — rendered messages and final status
- `processed_events` — Kafka idempotency barrier
- `delivery_log` — simulated provider attempts

All three writes occur in one transaction. Kafka offsets commit only after success.

## Configuration

| Variable | Default |
|---|---|
| `HTTP_ADDR` | `:8086` |
| `DATABASE_URL` | local `notifications_db` |
| `KAFKA_BROKERS` | `localhost:9092` |
| `KAFKA_SECURITY_PROTOCOL` | `PLAINTEXT` |
| `KAFKA_SASL_MECHANISM` | `PLAIN` |
| `KAFKA_SASL_USERNAME` | empty |
| `KAFKA_SASL_PASSWORD` | empty |
| `ORDERS_TOPIC` | `orders` |
| `KAFKA_CONSUMER_GROUP` | `notification-service-v1` |

Run with `make notification-run` or as part of `make compose-local-up`.


### Azure Event Hubs Kafka endpoint

Keep the local defaults for Docker Compose. For Azure Event Hubs, use `KAFKA_SECURITY_PROTOCOL=SASL_SSL` and `KAFKA_SASL_MECHANISM=PLAIN`. Set `KAFKA_SASL_USERNAME` to `$ConnectionString` and provide the Event Hubs namespace connection string through `KAFKA_SASL_PASSWORD`. TLS certificate verification remains enabled and requires TLS 1.2 or newer.
