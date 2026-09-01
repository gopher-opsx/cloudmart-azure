# Catalog Service

Read-only product catalog API backed by PostgreSQL `catalog_db`.

## Endpoints

- `GET /healthz`
- `GET /readyz`
- `GET /products`
- `GET /products/{id}`

## Configuration

| Variable | Default |
|---|---|
| `HTTP_ADDR` | `:8081` |
| `DATABASE_URL` | `postgres://cloudmart:cloudmart@localhost:5432/catalog_db?sslmode=disable` |

Run with `make catalog-run` or as part of `make compose-local-up`.
