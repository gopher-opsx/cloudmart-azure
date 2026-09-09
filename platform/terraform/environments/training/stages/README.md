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

## Section 12 activation boundaries

| Lesson | Newly enabled infrastructure |
|---|---|
| 73 | Container Apps managed OpenTelemetry agent routing traces/logs to Application Insights |
| 74 | No new resources; inspect logs, metrics, traces |
| 75 | No new resources; successful Saga observation |
| 76 | No new resources; deterministic business failure + compensation |
| 77 | CloudMart operations workbook and failed-revision log alert |
| 78 | HTTP concurrency scaling and Kafka-lag scaling |
| 79 | No permanent resources; controlled failed Order revision |
| 80 | No permanent resources; controlled database and Event Hubs dependency failures |
| 81 | No new resources; reliability/cost checkpoint |

Section 12 troubleshooting uses ignored `troubleshooting.auto.tfvars`.
Always remove it after the exercise:

```bash
./scripts/troubleshooting/disable-overrides.sh
```

## Section 13 activation boundaries

| Lesson | Newly enabled infrastructure |
|---|---|
| 82 | No Azure resources; CI/CD workflow boundary |
| 83 | GitHub OIDC deployment identity and scoped RBAC are bootstrapped outside Terraform |
| 84 | No Azure resources; build validation only |
| 85 | New SHA-tagged image manifests in the existing ACR |
| 86 | New Container App revisions from immutable release digests |
| 87 | No Azure resources; post-deployment smoke tests |
| 88 | Storefront switches to Multiple revision mode; promotion/rollback traffic is owned by CD |

Terraform intentionally ignores Container App traffic-weight drift. Infrastructure
code owns whether multiple revisions are supported; the release workflow owns
candidate/stable routing decisions.

## Section 14 lifecycle checkpoints

Lessons 89-95 do not activate new permanent application infrastructure beyond
the completed platform. Their stage files preserve the forward-only course
state while the final project exercises the lifecycle.

| Lesson | Final-project activity |
|---|---|
| 89 | Rebuild the complete CloudMart environment from the repository |
| 90 | Run consolidated end-to-end acceptance |
| 91 | Validate success and compensation Saga paths |
| 92 | Preserve security, observability, and delivery evidence |
| 93 | Record architecture, production evolution, and current cost position |
| 94 | Review and apply a saved Terraform destroy plan |
| 95 | Remove the separate state bootstrap and verify zero active CloudMart resources |

Use `.course/final-evidence/` for local sanitized evidence. The directory is
already excluded from Git.
