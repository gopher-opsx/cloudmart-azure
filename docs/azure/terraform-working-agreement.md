# CloudMart Terraform Working Agreement

## Terraform owns

- Azure infrastructure
- Resource configuration
- Supported tags
- Managed identities and RBAC
- Container App runtime configuration

## Application workflows own

- Application builds
- Automated tests
- Container image builds
- Database migrations
- Smoke tests
- Business data

## Working rules

1. Keep Terraform configuration in Git.
2. Format and validate before planning.
3. Review every plan before applying.
4. Stop on unexpected changes or destruction.
5. Avoid lasting manual changes to Terraform-managed resources.
6. Never commit Terraform state, credentials, or populated secret files.
7. Verify Azure after every meaningful apply.
8. Review destroy plans before removing infrastructure.
