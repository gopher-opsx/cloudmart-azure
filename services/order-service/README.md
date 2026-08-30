# Order Service

PostgreSQL-backed order service for CloudMart.

## Local defaults

- HTTP: `:8083`
- PostgreSQL: `postgres://cloudmart:cloudmart@localhost:5432/orders_db?sslmode=disable`

## Local customer identity

Until the Web BFF/OIDC layer is added, requests identify the customer with:

```text
X-Customer-ID: customer-001
```

## Endpoints

- `GET /healthz`
- `GET /readyz`
- `POST /orders`
- `GET /orders/{id}`
- `GET /orders`

New orders start in `pending`. The next batch will add a transactional outbox and Kafka `order.created` events without redesigning the core tables.
