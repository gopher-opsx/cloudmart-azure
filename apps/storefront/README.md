# CloudMart Storefront

Angular 21 standalone storefront for browsing products, managing a cart, placing orders, and following the final Saga state.

## Runtime behavior

The storefront calls only relative `/api` routes.

During Angular development, `proxy.conf.json` forwards those requests to the Web BFF at `http://localhost:8080`.

The production container uses the prepared Nginx runtime template in `nginx.conf.template`. The upstream BFF address is injected when the container starts through `BFF_UPSTREAM`, so the same Storefront image can run locally and in Azure without rebuilding the Angular application.

Default Docker/Compose value:

```text
BFF_UPSTREAM=http://web-bff:8080
```

Azure Container Apps value:

```text
BFF_UPSTREAM=http://ca-web-bff-training
```

If the BFF is unavailable, the UI enters preview mode with local sample data. Preview checkout never creates backend state.

## Run locally

```bash
npm ci
npm start
```

Open `http://localhost:4200`, or run `make storefront-run` from the repository root.

## Verify

```bash
npm test -- --watch=false
npm run build
```

The production image is built from `Dockerfile` and served by Nginx.

To override the production-container BFF target manually:

```bash
docker run --rm \
  -p 4200:80 \
  -e BFF_UPSTREAM=http://host.docker.internal:8080 \
  cloudmart/storefront:local
```

## Customer identity

The training UI uses `customer-storefront-demo`. The BFF forwards `X-Customer-ID` to Cart and Order. Microsoft Entra ID will replace this local identity mechanism during the Azure phase.
