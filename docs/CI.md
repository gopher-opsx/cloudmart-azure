# Continuous integration

CloudMart uses GitHub Actions as an independent quality gate. The workflow runs for pull requests and pushes to `main`, and can also be started manually.

It validates all seven Go modules, tests and builds the Angular storefront, validates the merged Compose configuration, and builds all eight application images without publishing them.

Run the prepared local checks from the repository root:

```bash
bash scripts/ci/test-cloudmart.sh
bash scripts/ci/validate-images.sh

docker compose \
  -f platform/docker/compose.yaml \
  -f platform/docker/compose.observability.yaml \
  config --quiet
```

The GitHub Actions workflow remains the authoritative CI implementation. These helpers provide a convenient local preflight before pushing changes.

The workflow intentionally performs CI only. Azure authentication, ACR publication, and deployment belong to the later CD workflow. No repository or Azure secrets are required for this CI workflow.
