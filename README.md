# CloudMart Azure

CloudMart is a cloud-native e-commerce reference application built to demonstrate a practical migration from a local Docker-based environment to a production Azure platform.

## Planned Stack

### Frontend
- Angular 21 LTS

### Backend
- Go 1.26.x
- REST APIs
- Kafka-based asynchronous workflows

### Local Platform
- Docker Compose
- PostgreSQL
- Redis
- Kafka
- MinIO
- OpenTelemetry Collector
- Prometheus
- Grafana

### Azure Target
- Azure Container Registry
- Azure Kubernetes Service
- Azure Database for PostgreSQL
- Azure Managed Redis
- Azure Event Hubs Kafka endpoint
- Azure Blob Storage
- Microsoft Entra ID
- Azure Key Vault
- Azure Monitor
- Application Insights
- Terraform
- Azure DevOps

## Repository Structure

- `apps/` — frontend applications
- `services/` — Go microservices
- `libs/` — shared technical Go libraries
- `contracts/` — OpenAPI, AsyncAPI, and event schemas
- `platform/` — local Docker infrastructure
- `deploy/` — Kubernetes deployment assets
- `infra/` — Azure infrastructure as code
- `pipelines/` — CI/CD definitions
- `tests/` — integration, contract, end-to-end, and load tests
- `docs/` — architecture, ADRs, runbooks, and migration documentation

## Current Status

Project foundation only. Application implementation has not started yet.
