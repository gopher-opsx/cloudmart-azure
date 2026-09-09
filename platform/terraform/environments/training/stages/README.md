# Terraform course stages

The complete CloudMart Terraform configuration lives on `main`.

Whenever a lesson runs `terraform plan`, use the tfvars file matching that
lesson number:

```bash
terraform plan \
  -var-file=stages/lesson-024.tfvars \
  -out=cloudmart-training.tfplan
```

A later lesson uses its own stage:

```bash
terraform plan \
  -var-file=stages/lesson-035.tfvars \
  -out=cloudmart-training.tfplan
```

The `course_stage` value activates only the infrastructure introduced up to
that lesson.

Current activation boundaries:

| Lesson | Infrastructure enabled |
|---|---|
| 22 | No CloudMart workload resources |
| 23 | Resource Group |
| 26 | + Azure Container Registry |
| 27 | + operator `AcrPush` |
| 32 | + Log Analytics |
| 33 | + Container Apps Environment |
| 34 | + Application Insights |
| 35 | + Key Vault |
| 36 | + user-assigned managed identities |
| 37 | + workload `AcrPull` and Key Vault RBAC |

Lessons between those boundaries keep the previous infrastructure set active.

Always move forward through course stages in a live environment. Planning with
an earlier lesson stage after later infrastructure has been applied can
correctly propose destroying later resources.
