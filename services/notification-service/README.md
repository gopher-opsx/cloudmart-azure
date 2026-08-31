# CloudMart Notification Service

Consumes `order.confirmed` and `order.cancelled` events from the Kafka `orders` topic using the independent `notification-service-v1` consumer group. Each accepted event is stored exactly once in `notifications_db`; a simulated email delivery and its attempt are recorded atomically with `processed_events`.

## Configuration

| Variable | Default |
|---|---|
| `HTTP_ADDR` | `:8086` |
| `DATABASE_URL` | `postgres://cloudmart:cloudmart@localhost:5432/notifications_db?sslmode=disable` |
| `KAFKA_BROKERS` | `localhost:9092` |
| `ORDERS_TOPIC` | `orders` |
| `KAFKA_CONSUMER_GROUP` | `notification-service-v1` |

## Endpoints

- `GET /healthz`: process liveness
- `GET /readyz`: PostgreSQL readiness

## Data model

- `notifications`: rendered customer messages and final delivery status
- `processed_events`: idempotency barrier for Kafka redelivery
- `delivery_log`: append-only simulated provider attempts

The processed marker, notification, and delivery log entry are committed in one PostgreSQL transaction. Kafka offsets are committed only after that transaction succeeds.

## Run

Apply `migrations/001_create_notifications.sql`, then run `go run ./cmd/worker`. See `NOTIFICATION_SERVICE_BATCH.md` at repository root for Docker-based steps.
