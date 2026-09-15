# ADR 001 — Use Azure Container Apps for CloudMart

## Decision

Deploy each CloudMart application component as an independent
Azure Container App inside a shared Container Apps environment.

## Why

CloudMart requires:

- Existing Linux container images
- HTTP services and background workers
- Independent service deployment and scaling
- Internal application communication
- Health checks
- Managed identity and secrets
- Observability

CloudMart does not currently require direct Kubernetes
cluster control.

## Alternatives considered

- Azure Kubernetes Service
- Azure App Service
- Azure Container Instances
- Azure Functions

## Consequence

CloudMart uses a managed container application platform while
Azure handles more of the underlying orchestration infrastructure.
