# Order Service

Owns order creation, queries, final status, and the orchestration edges of the Kafka Saga. Durable data is stored in PostgreSQL `orders_db`.

## HTTP endpoints

- `GET /healthz`
- `GET /readyz`
- `POST /orders`
- `GET /orders`
- `GET /orders/{id}`

Customer-scoped routes require `X-Customer-ID`.

## Events

Produces `order.created`, `order.confirmed`, and `order.cancelled` on `orders`. Consumes `payment.authorized` and `payment.failed` from `payments` using consumer group `order-service-payments`.

The transactional outbox prevents database state and Kafka publication from diverging. `processed_events` makes payment handling idempotent.

## Configuration

| Variable | Default |
|---|---|
| `HTTP_ADDR` | `:8083` |
| `DATABASE_URL` | local `orders_db` |
| `KAFKA_BROKERS` | `localhost:9092` |
| `KAFKA_SECURITY_PROTOCOL` | `PLAINTEXT` |
| `KAFKA_SASL_MECHANISM` | `PLAIN` |
| `KAFKA_SASL_USERNAME` | empty |
| `KAFKA_SASL_PASSWORD` | empty |
| `ORDERS_TOPIC` | `orders` |
| `PAYMENTS_TOPIC` | `payments` |
| `PAYMENTS_CONSUMER_GROUP` | `order-service-payments` |

Run with `make order-run` or as part of `make compose-local-up`.


### Azure Event Hubs Kafka endpoint

Keep the local defaults for Docker Compose. For Azure Event Hubs, use `KAFKA_SECURITY_PROTOCOL=SASL_SSL` and `KAFKA_SASL_MECHANISM=PLAIN`. Set `KAFKA_SASL_USERNAME` to `$ConnectionString` and provide the Event Hubs namespace connection string through `KAFKA_SASL_PASSWORD`. TLS certificate verification remains enabled and requires TLS 1.2 or newer.
