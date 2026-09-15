# CloudMart Target Azure Architecture

## Compute

- Azure Container Apps
- One Container App per application component
- Azure Container Registry for images

## Data

- PostgreSQL Flexible Server for durable relational data
- Separate service-owned databases
- Azure Managed Redis for temporary cart state

## Messaging

- Azure Event Hubs with Kafka compatibility
- orders
- inventory
- payments

## Security

- Managed identities
- Azure RBAC
- Azure Key Vault
- Controlled application ingress

## Observability

- Azure Monitor
- Log Analytics
- Application Insights
- OpenTelemetry

## Delivery

- Terraform as infrastructure source of truth
- Azure Storage for remote Terraform state
- GitHub Actions for CI/CD

## Training baseline

- East US
- Small supported SKUs
- Cost controls
- Secure training connectivity
- Deliberate teardown
