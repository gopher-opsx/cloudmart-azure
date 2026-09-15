# Bash script reference

The `scripts/` directory is CloudMart’s operational toolbox. These helpers do not replace Docker, Terraform, or Azure CLI; they combine repeatable command-line steps for bootstrap, delivery, verification, troubleshooting, and cleanup.

Run course helpers from the repository root with `bash scripts/<path>/<script>.sh` unless a lesson says otherwise. Read a script before adapting it to another environment, especially helpers that create, update, or delete Azure resources.

## How to read these scripts

- **Docker** packages and runs application components.
- **Terraform** owns the desired Azure infrastructure state.
- **Azure CLI (`az`)** inspects Azure and performs direct operational/bootstrap actions.
- **Bash** sequences those commands, validates inputs, handles failures, and removes repetitive typing.

Common safety pattern: `set -euo pipefail` stops Bash when a command fails, an unset variable is used, or a pipeline fails. Most course scripts also source `scripts/lib/course-common.sh` for consistent `info`, `pass`, `fail`, and prerequisite checks.

## Acceptance and final validation

| Script | What it does |
|---|---|
| `scripts/acceptance/capture-final-evidence.sh` | Captures sanitized final-course evidence from security, release, runtime, and Azure checks. Runs existing verification helpers and writes their outputs to a local evidence directory for review. |
| `scripts/acceptance/final-preflight.sh` | Checks that the workstation has the commands, Azure login, and repository state required for the final project. Fails early when a prerequisite is missing so the rebuild is not started from an invalid environment. |
| `scripts/acceptance/verify-course-cleanup.sh` | Verifies that CloudMart workload resources, bootstrap state, and the GitHub OIDC identity are no longer active. Queries Azure after teardown and fails if course-owned resources or identity objects still remain. |
| `scripts/acceptance/verify-final-system.sh` | Runs the machine-repeatable acceptance checks for the completed Azure deployment. Combines platform, release, runtime, security, and smoke verification into one final gate. |
| `scripts/acceptance/verify-workload-destroyed.sh` | Confirms that the Terraform-managed CloudMart workload has been removed. Checks Azure for remaining workload resource groups/resources and reports a clean teardown only when none remain. |

## Bootstrap and identity

| Script | What it does |
|---|---|
| `scripts/bootstrap/configure-github-oidc.sh` | Creates or reuses the Microsoft Entra application, service principal, and federated credential used by GitHub Actions. Grants the minimum Azure roles required for OIDC-based image publishing and Container Apps delivery. |
| `scripts/bootstrap/create-tfstate.sh` | Bootstraps the Azure Storage backend used for Terraform remote state. Creates the state resource group/account/container, grants data access, and prints the backend values for Terraform. |
| `scripts/bootstrap/destroy-github-oidc.sh` | Removes the course GitHub Actions OIDC application and service principal from Microsoft Entra ID. Requires an explicit confirmation value before deleting the separately managed deployment identity. |
| `scripts/bootstrap/destroy-tfstate.sh` | Deletes the separately bootstrapped Terraform-state storage resources after workload teardown. Uses explicit confirmation and Azure CLI checks so remote state is removed only at the end of the course lifecycle. |

## CI/CD and release delivery

| Script | What it does |
|---|---|
| `scripts/cd/candidate-verify.sh` | Verifies a Storefront candidate revision before production traffic is increased. Checks the candidate endpoint and application behavior so promotion is based on a working revision. |
| `scripts/cd/create-workflow-release-manifest.sh` | Creates the immutable release manifest used by the GitHub Actions delivery jobs. Resolves each CloudMart image to a registry digest and records the Git SHA for repeatable deployment. |
| `scripts/cd/deploy-container-apps.sh` | Deploys the image digests from a release manifest to the CloudMart Container Apps. Updates each app to an immutable image reference and can intentionally skip Storefront for candidate-safe rollout. |
| `scripts/cd/prepare-storefront-candidate.sh` | Creates a new Storefront revision that can be tested before receiving normal user traffic. Deploys the candidate image and prepares revision metadata used by verification and traffic-shifting steps. |
| `scripts/cd/promote-storefront.sh` | Promotes the verified Storefront candidate to production traffic. Moves the public traffic weight to the candidate revision after the release gate has passed. |
| `scripts/cd/rollback-storefront.sh` | Rolls Storefront traffic back to the previously stable revision. Finds the stable revision and restores traffic without rebuilding the application images. |
| `scripts/cd/set-storefront-traffic.sh` | Applies explicit traffic weights to Storefront revisions in Azure Container Apps. Provides the reusable Azure CLI operation used by candidate, promotion, and rollback workflows. |
| `scripts/cd/smoke-test.sh` | Runs the synchronous post-deployment smoke gate through the public Storefront URL. Validates HTTPS, health, products, cart add/read/cleanup, and Order API reachability using a temporary customer. |
| `scripts/cd/verify-release.sh` | Checks that the deployed Container Apps are healthy after a release. Verifies provisioning state and active revisions so a delivery job can fail before declaring success. |

## Continuous integration

| Script | What it does |
|---|---|
| `scripts/ci/test-cloudmart.sh` | Runs the application test suite used by CI before images are built or deployed. Executes the Go and Angular validation commands from a single repeatable entry point. |
| `scripts/ci/validate-images.sh` | Builds or validates all CloudMart container images as a CI quality gate. Catches Dockerfile and build-context failures across the eight deployable components before release. |

## Container Apps runtime

| Script | What it does |
|---|---|
| `scripts/container-apps/verify-backend-runtime.sh` | Verifies the deployed backend Container Apps and their runtime health in Azure. Checks expected apps/revisions and surfaces failures before higher-level acceptance tests continue. |

## Data services

| Script | What it does |
|---|---|
| `scripts/data/run-postgres-migrations.sh` | Applies the prepared PostgreSQL schema migrations to the Azure databases. Uses supplied PostgreSQL connection values and runs each service migration in the required order. |
| `scripts/data/verify-managed-redis.sh` | Checks connectivity and configuration for Azure Managed Redis used by the Cart service. Queries the deployed cache and validates the expected secure runtime settings. |
| `scripts/data/verify-postgres.sh` | Verifies the Azure PostgreSQL server, databases, and expected connectivity prerequisites. Uses Azure and PostgreSQL checks to confirm the data tier is ready for application workloads. |

## Final project

| Script | What it does |
|---|---|
| `scripts/final-project/post-provision.sh` | Runs the acceptance sequence after the final Terraform rebuild has completed. Delegates to the final-system verifier so the rebuilt environment must pass the same reusable checks. |
| `scripts/final-project/prepare-release.sh` | Prepares a fresh application release for the final rebuild exercise. Builds/pushes images, records digests, renders Terraform release inputs, and runs database migrations. |
| `scripts/final-project/reset-workload.sh` | Destroys the Terraform-managed workload before the final rebuild exercise. Performs the guarded reset and then verifies that the workload resources are actually gone. |
| `scripts/final-project/run-migrations.sh` | Runs the database-migration phase used by the final-project workflow. Collects the required Terraform/Azure outputs and invokes the shared PostgreSQL migration helper. |

## Shared library

| Script | What it does |
|---|---|
| `scripts/lib/course-common.sh` | Provides shared logging, validation, Azure, and assertion helpers used by the course scripts. This file is sourced by other Bash scripts so common behavior and error handling stay consistent. |

## Load generation

| Script | What it does |
|---|---|
| `scripts/load/generate-http-load.sh` | Generates controlled HTTP traffic against a CloudMart endpoint for scaling and observability labs. Sends repeated requests with configurable concurrency/count so students can watch platform behavior under load. |
| `scripts/load/generate-kafka-lag.sh` | Generates controlled Event Hubs/Kafka backlog for worker-scaling demonstrations. Publishes synthetic messages to create measurable consumer lag without requiring real checkout traffic. |

## Release metadata

| Script | What it does |
|---|---|
| `scripts/release/prepare-image-release.sh` | Generates the local release metadata file from Terraform, Azure, and Git. Resolves ACR details and the current Git SHA so students avoid manually copying release values. |

## Security

| Script | What it does |
|---|---|
| `scripts/security/audit-container-app-env.sh` | Audits Container App environment variables for the expected secure runtime configuration. Inspects deployed settings and reports values that violate the course security baseline. |
| `scripts/security/audit-container-app-ingress.sh` | Audits which Container Apps are public and which are internal-only. Verifies the intended ingress boundary: Storefront public, application backends private. |
| `scripts/security/audit-key-vault-references.sh` | Checks that sensitive Container App settings are sourced from Azure Key Vault references. Detects deployments that bypass the expected secret-reference pattern. |
| `scripts/security/audit-managed-identities.sh` | Verifies that CloudMart Azure workloads have the expected managed identities attached. Confirms identity-based access is present before dependent RBAC and secret checks are trusted. |
| `scripts/security/audit-plaintext-config.sh` | Scans deployed Container App configuration for secrets that appear directly in environment values. Fails the security gate when sensitive configuration is exposed instead of referenced securely. |
| `scripts/security/audit-rbac.sh` | Audits the important Azure RBAC assignments used by CloudMart workloads. Checks that managed identities have the expected scoped permissions without relying on broad shared credentials. |
| `scripts/security/audit-transport.sh` | Runs transport-security checks for the CloudMart ingress path. Combines HTTPS/ingress verification so external traffic follows the intended secure boundary. |
| `scripts/security/verify-security-baseline.sh` | Runs all prepared CloudMart security audits as one baseline gate. Executes the individual identity, secret, RBAC, ingress, and transport checks and stops on the first failure. |

## Terraform helpers

| Script | What it does |
|---|---|
| `scripts/terraform/course-apply.sh` | Applies a selected progressive CloudMart Terraform lesson stage. Wraps Terraform apply with the course backend/stage conventions so lesson execution stays repeatable. |
| `scripts/terraform/course-plan.sh` | Creates a Terraform plan for a selected CloudMart course stage. Loads the prepared backend/stage inputs and shows the infrastructure change before anything is applied. |
| `scripts/terraform/course-stage.sh` | Resolves and validates the Terraform stage file associated with a lesson number. Provides shared stage-selection logic used by the course plan/apply helpers. |
| `scripts/terraform/render-release-tfvars.sh` | Renders Terraform image inputs from the recorded immutable CloudMart release digests. Produces the generated release tfvars consumed by infrastructure deployment without hand-copying image references. |

## Troubleshooting

| Script | What it does |
|---|---|
| `scripts/troubleshooting/disable-overrides.sh` | Removes temporary Terraform troubleshooting overrides and returns the course configuration to normal. Deletes the controlled-failure tfvars file so the next plan restores the intended source of truth. |
| `scripts/troubleshooting/enable-bad-order-image.sh` | Enables the controlled bad-image scenario used to troubleshoot a failed Order revision. Writes a temporary Terraform override that points Order at an intentionally invalid image reference. |
| `scripts/troubleshooting/enable-catalog-db-failure.sh` | Enables the controlled Catalog database-connectivity failure used in troubleshooting labs. Writes a temporary Terraform override so Catalog fails its startup database check in a predictable way. |
| `scripts/troubleshooting/enable-inventory-kafka-failure.sh` | Enables the controlled Inventory Event Hubs/Kafka authentication failure. Writes a temporary Terraform override that switches Inventory to the intentionally invalid Key Vault credential. |

## General operational helpers

| Script | What it does |
|---|---|
| `scripts/build-and-push-cloudmart-images.sh` | Builds the CloudMart application images and pushes the release set to Azure Container Registry. Uses prepared release metadata so every service image is tagged consistently for the current release. |
| `scripts/record-cloudmart-image-digests.sh` | Resolves pushed CloudMart images to immutable ACR digests and records them for deployment. Turns mutable tags into stable digest references that Terraform and release workflows can consume safely. |
| `scripts/smoke-business-metrics.sh` | Exercises business operations that produce useful application metrics for observability labs. Creates predictable traffic so students can verify that business-level telemetry appears in the monitoring stack. |
| `scripts/smoke-local.sh` | Validates the complete local CloudMart business flow through the Web BFF. Creates one successful and one compensated order, then waits for confirmed and cancelled Saga outcomes. |
| `scripts/smoke-metrics.sh` | Checks that the local services expose Prometheus-format metrics after traffic has been generated. Queries metric endpoints and verifies expected application telemetry is available for scraping. |
| `scripts/verify-event-hubs-kafka.sh` | Verifies the Event Hubs Kafka-compatible endpoint and required messaging configuration. Checks the Azure namespace/hub/auth setup before event-driven services depend on it. |
| `scripts/verify-platform-foundation.sh` | Verifies the main Azure platform foundation created by Terraform. Checks the expected resource group and core shared services before workload deployment proceeds. |

## Reusing the patterns in day-to-day work

Treat these scripts as reference implementations rather than copy-paste magic. The most reusable patterns are prerequisite checks, explicit environment-variable validation, loops over multiple resources, retry logic for cloud propagation, immutable image-digest handling, guarded destructive actions, and small verification scripts that return a non-zero exit code when a condition is wrong.

When adapting a helper for another project, keep the ownership rule clear: change Terraform-owned infrastructure through Terraform, use CLI/Bash for operational or bootstrap work, and keep secrets out of source control and terminal output.

