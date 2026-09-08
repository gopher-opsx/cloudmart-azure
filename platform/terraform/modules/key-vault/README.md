# Key Vault module

Creates the CloudMart training Azure Key Vault.

Training baseline:

- SKU: Standard
- Authorization model: Azure RBAC
- Soft-delete retention: 7 days
- Purge protection: disabled for the disposable training environment
- Public network access: enabled

This module intentionally does **not** create secrets, role assignments, or
managed identities. Those are introduced in later lessons so the course
sequence remains visible during recording.
