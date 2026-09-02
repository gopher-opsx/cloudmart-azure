# Continuous integration

CloudMart uses GitHub Actions as an independent quality gate. The workflow runs for pull requests and pushes to `main`, and can also be started manually.

It validates all seven Go modules, tests and builds the Angular storefront, validates the merged Compose configuration, and builds all eight application images without publishing them.

Run the equivalent fast checks locally from the repository root:

```bash
make ci-local
```

The local target runs Go tests inside Linux containers, which avoids Windows Application Control blocking temporary Go test executables.

The workflow intentionally performs CI only. Azure authentication, ACR publication, and deployment belong to the later CD workflow. No repository or Azure secrets are required for this CI workflow.
