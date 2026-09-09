# CloudMart Azure — Final Project Record

Use this document as the sanitized engineering record for the completed course.

## Repository

- Git commit:
- Release tag:
- Course completion date:

## Architecture

- Runtime: Azure Container Apps
- Registry: Azure Container Registry
- Relational data: Azure Database for PostgreSQL Flexible Server
- Cart state: Azure Managed Redis
- Messaging: Azure Event Hubs Kafka endpoint
- Secrets: Azure Key Vault
- Workload authentication: user-assigned managed identities
- Observability: OpenTelemetry, Application Insights, Log Analytics, Azure Monitor
- Delivery: GitHub Actions + Microsoft Entra workload identity federation

## Final validation

Record PASS/FAIL only. Do not paste credentials or Terraform state.

- Terraform stable:
- 8 Container Apps healthy:
- Public Storefront:
- Internal service discovery:
- Catalog:
- Cart:
- Successful Saga:
- Compensating Saga:
- Security baseline:
- Logs:
- Metrics:
- Traces:
- Scaling:
- CI:
- CD:
- Candidate rollout:
- Rollback:

## Training compromises

Record the deliberate course choices and their production evolution.

- Public PostgreSQL endpoint with narrow admin rule plus Azure-services training rule
- Public training access to selected managed services
- Cost-minimized SKUs / replica counts
- Key Vault purge protection disabled only for disposable training cleanup
- SAS-based Event Hubs Kafka authentication for application compatibility

## Production evolution

Examples to evaluate:

- private endpoints / private DNS
- controlled egress
- stronger HA / DR
- identity-based data-plane authentication where supported
- organization landing-zone integration
- policy enforcement
- environment separation
- SLO-driven alerting and capacity planning

## Cost position

- Date reviewed:
- Major active cost drivers:
- Approximate course spend:
- Billing data delay explained:

Record the Git revision, Azure region, architecture decisions, deployed services, release SHA/digests, Saga evidence, security/observability/CI-CD status, reported cost, production improvements, and final teardown evidence.
