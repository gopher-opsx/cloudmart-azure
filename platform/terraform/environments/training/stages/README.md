# Terraform course stages

The complete CloudMart Terraform configuration lives on `main`.

During the course, **always** select the stage file that matches the current
lesson whenever you run a Terraform plan:

```bash
terraform plan \
  -var-file=stages/lesson-035.tfvars \
  -out=cloudmart-training.tfplan
```

The stage file contains only:

```hcl
course_stage = 35
```

The root configuration uses `course_stage` to decide which parts of the
complete course infrastructure are active.

## Why every lesson has a stage file

The repository intentionally contains stage files from Lesson 22 through
Lesson 95, even when a particular lesson does not introduce a new Terraform
resource.

That gives the recording a simple rule:

> Current lesson number = current Terraform stage file.

The actual activation boundaries are recorded in `course-stages.tsv`.

## Safety rule: move forward

Do not plan an earlier stage after you have applied a later one unless you
intentionally want Terraform to remove later resources.

For example, after applying Lesson 37, planning Lesson 23 can correctly propose
destroying resources introduced by Lessons 26-37.

The helper scripts under `scripts/terraform/` detect this and refuse a backward
stage by default.

## Native Terraform remains the course workflow

The lesson content continues to show normal Terraform commands. The helper
scripts are safety/convenience tools, not a replacement for learning
Terraform.

Before a recording, you can inspect the current and target stage:

```bash
./scripts/terraform/course-stage.sh 35
```

Or use the guarded planner:

```bash
./scripts/terraform/course-plan.sh 35
```

The guarded planner performs `terraform validate` and writes a saved plan under
`.course/terraform-plans/`.

## Section 7 activation boundaries

| Lesson | Newly enabled infrastructure |
|---|---|
| 39 | PostgreSQL Flexible Server |
| 40 | Narrow PostgreSQL administration firewall rule |
| 41 | Five service-owned PostgreSQL databases |
| 42 | No new Terraform resources; application migrations run |
| 43 | Azure Managed Redis |
| 44 | No new Terraform resources; Cart Service integration test runs |
| 45 | No new resources; data-platform checkpoint |

## Section 8 activation boundaries

| Lesson | Newly enabled infrastructure |
|---|---|
| 46 | No new resources; Kafka/Event Hubs architecture |
| 47 | Event Hubs namespace |
| 48 | `orders`, `inventory`, and `payments` Event Hubs |
| 49 | No new resources; validate Kafka consumer runtime contract |
| 50 | Scoped namespace SAS rule with `Send` + `Listen`, no `Manage` |
| 51 | No new Terraform resources; temporary connectivity-test Event Hub is created and removed by the verification script |
| 52 | No new resources; messaging architecture checkpoint |

## Section 9 activation boundaries

| Lesson | Newly enabled infrastructure |
|---|---|
| 53 | No new resources; ingress and deployment contract checkpoint |
| 54 | Catalog Container App, Catalog DB secret, training PostgreSQL Azure-services firewall rule |
| 55 | Cart Container App and Redis Key Vault secret |
| 56 | Order Container App, Order DB secret, shared Event Hubs secret |
| 57 | Inventory worker Container App and DB secret |
| 58 | Payment worker Container App and DB secret |
| 59 | Notification worker Container App and DB secret |
| 60 | Standard health probes and backend right-sizing |
| 61 | No new resources; internal service discovery/runtime verification |

Before Lesson 54, generate local Terraform image inputs from the immutable
Section 5 release manifest:

```bash
./scripts/terraform/render-release-tfvars.sh
```

The generated `release.auto.tfvars.json` is local and ignored by Git.

## Sections 10-11 activation boundaries

| Lesson | Newly enabled infrastructure |
|---|---|
| 62 | Internal Web BFF Container App |
| 63 | No new resources; verify BFF-to-service connectivity |
| 64 | Public Storefront Container App |
| 65 | No new resources; verify HTTPS edge and same-origin browser path |
| 66 | No new resources; full user-facing-path checkpoint |
| 67 | No new Azure resources; consolidate/audit Key Vault secret usage |
| 68 | No new resources; verify one managed identity per workload |
| 69 | No new resources; plaintext-configuration audit |
| 70 | No new resources; least-privilege RBAC audit |
| 71 | No new resources; ingress and transport audit |
| 72 | No new resources; consolidated security checkpoint |

The security section intentionally does not create an insecure intermediate
state. Backend services use Key Vault references from their first Azure
deployment. Lessons 67-72 audit and explain that security model rather than
temporarily exposing secrets in plaintext.
