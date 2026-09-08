# Inventory Service

Kafka worker responsible for reserving and compensating stock in PostgreSQL `inventory_db`.

## Events

Consumes `order.created` and `order.cancelled` from `orders` using consumer group `inventory-service`.

Produces:

- `inventory.reserved`
- `inventory.rejected`
- `inventory.released`

`inventory_reservations` records item quantities per order so cancellation can restore stock exactly once. Inventory mutations, processed-event markers, and outbox records commit in one transaction.

## Configuration

| Variable | Default |
|---|---|
| `HTTP_ADDR` | `:8084` |
| `DATABASE_URL` | local `inventory_db` |
| `KAFKA_BROKERS` | `localhost:9092` |
| `KAFKA_SECURITY_PROTOCOL` | `PLAINTEXT` |
| `KAFKA_SASL_MECHANISM` | `PLAIN` |
| `KAFKA_SASL_USERNAME` | empty |
| `KAFKA_SASL_PASSWORD` | empty |
| `ORDERS_TOPIC` | `orders` |
| `INVENTORY_TOPIC` | `inventory` |
| `KAFKA_CONSUMER_GROUP` | `inventory-service` |

Run with `make inventory-run` or as part of `make compose-local-up`.


### Azure Event Hubs Kafka endpoint

Keep the local defaults for Docker Compose. For Azure Event Hubs, use `KAFKA_SECURITY_PROTOCOL=SASL_SSL` and `KAFKA_SASL_MECHANISM=PLAIN`. Set `KAFKA_SASL_USERNAME` to `$ConnectionString` and provide the Event Hubs namespace connection string through `KAFKA_SASL_PASSWORD`. TLS certificate verification remains enabled and requires TLS 1.2 or newer.
