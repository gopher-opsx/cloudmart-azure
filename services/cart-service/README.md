# Cart Service

Redis-backed shopping cart service for CloudMart.

## Local defaults

- HTTP: `:8082`
- Redis: `localhost:6379`
- Cart TTL: `24h`

## Customer identity during local development

Until the Web BFF/OIDC layer is added, requests identify the customer with:

```text
X-Customer-ID: customer-001
```

The BFF will own customer identity propagation later.

## Endpoints

- `GET /healthz`
- `GET /readyz`
- `GET /cart`
- `POST /cart/items`
- `PATCH /cart/items/{productId}`
- `DELETE /cart/items/{productId}`
- `DELETE /cart`
