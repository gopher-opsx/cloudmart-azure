# CloudMart Storefront

Angular 21 standalone storefront for browsing products, managing a cart, placing orders, and following the final Saga state.

## Runtime behavior

The storefront calls only relative `/api` routes. During development, `proxy.conf.json` forwards them to the Web BFF at `http://localhost:8080`. In the production container, Nginx forwards them to the Compose `web-bff` service.

If the BFF is unavailable, the UI enters preview mode with local sample data. Preview checkout never creates backend state.

## Run

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

The production image is built from `Dockerfile` and served by Nginx using `nginx.conf`.

## Customer identity

The training UI uses `customer-storefront-demo`. The BFF forwards `X-Customer-ID` to Cart and Order. Microsoft Entra ID will replace this local identity mechanism during the Azure phase.
