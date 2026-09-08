# Container Registry module

Creates the CloudMart Azure Container Registry used by the course image-release workflow.

Training baseline:

- Basic SKU
- admin account disabled
- public network access enabled
- Microsoft Entra ID authentication used by operators and workloads

The module intentionally does not create role assignments. Interactive `AcrPush` access is added in the next lesson/batch so Lesson 26 creates only the registry.
