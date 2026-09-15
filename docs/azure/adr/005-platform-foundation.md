# ADR 005 — Define CloudMart Platform Foundation

## Identity

- Humans use interactive Azure authentication.
- GitHub Actions uses OIDC federation.
- Container Apps use managed identities.
- Access follows least privilege.

## Secrets

- Sensitive values are protected with Azure Key Vault.
- Secrets are not committed to Git.
- Secrets are not baked into container images.

## Application exposure

- Storefront: external
- Web BFF: internal
- Catalog: internal
- Cart: internal
- Order: internal
- Inventory: no application ingress
- Payment: no application ingress
- Notification: no application ingress

## Managed services

CloudMart uses secure, authenticated connections to:

- PostgreSQL
- Managed Redis
- Event Hubs
- Key Vault

## Observability

- Log Analytics for logs
- Azure Monitor for platform monitoring
- OpenTelemetry retained in the application
- Application Insights for application telemetry
- Trace correlation preserved across service boundaries
