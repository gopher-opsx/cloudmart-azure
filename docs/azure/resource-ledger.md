# CloudMart Azure Resource Ledger

## Environment

| Field | Value |
|---|---|
| Workload | CloudMart |
| Environment | training |
| Region | East US |
| Subscription | CloudMart-Azure-Training |
| Budget | budget-cloudmart-training |
| Status | planned |

## Lifecycle

- planned
- active
- destroyed

## Resource ledger

| Component | Azure service | Managed by | Cost attention | Status |
|---|---|---|---|---|
| Terraform state | Storage Account | Terraform bootstrap | Retained storage | planned |
| Container images | Container Registry | Terraform | Stored images | planned |
| Application runtime | Container Apps | Terraform | Running compute | planned |
| Relational data | PostgreSQL | Terraform | Compute + storage | planned |
| Cart data | Managed Redis | Terraform | Provisioned capacity | planned |
| Messaging | Event Hubs | Terraform | Messaging capacity | planned |
| Secrets | Key Vault | Terraform | Low / usage based | planned |
| Identity | Managed Identity + RBAC | Terraform | Access lifecycle | planned |
| Monitoring | Azure Monitor | Terraform | Telemetry ingestion | planned |
| Delivery | GitHub Actions identity | Terraform / GitHub | Access lifecycle | planned |

## Teardown verification

- [ ] CloudMart application resources removed
- [ ] Data services removed
- [ ] Messaging resources removed
- [ ] Monitoring resources removed
- [ ] Container Registry removed
- [ ] Managed identities and CloudMart access removed
- [ ] Workload resource group removed
- [ ] Terraform-state infrastructure removed
- [ ] No unexpected CloudMart resources remain
- [ ] Final cost review completed
