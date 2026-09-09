# Generic CloudMart Container App module

This module is the shared deployment primitive used by the CloudMart services.

It supports:

- one user-assigned managed identity
- ACR image pull through that identity
- immutable image references
- normal and secret-backed environment variables
- Key Vault secret references
- external, internal, or disabled ingress
- explicit CPU and memory
- minimum and maximum replicas
- startup, liveness, and readiness probes

The course deliberately keeps application-specific runtime contracts in the
`training` root module instead of hiding them inside this reusable module.
