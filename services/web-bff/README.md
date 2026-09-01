# CloudMart Web BFF

Browser-facing API gateway for the CloudMart storefront. It exposes a single origin on port `8080`, routes product requests to Catalog, cart requests to Cart, and order requests to Order Service, while forwarding customer and tracing headers.

## Endpoints

- `GET /healthz`
- `GET /readyz` (Catalog, Cart, and Order readiness)
- `/api/products...` → Catalog Service
- `/api/cart...` → Cart Service
- `/api/orders...` → Order Service

## Configuration

| Variable | Default |
|---|---|
| `HTTP_ADDR` | `:8080` |
| `CATALOG_SERVICE_URL` | `http://localhost:8081` |
| `CART_SERVICE_URL` | `http://localhost:8082` |
| `ORDER_SERVICE_URL` | `http://localhost:8083` |
| `ALLOWED_ORIGIN` | `http://localhost:4200` |
