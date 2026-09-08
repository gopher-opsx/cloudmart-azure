# Naming and Region

Training baseline region: East US. Resource names use the `cloudmart-training` intent where service naming constraints allow it. Keep globally unique service suffixes configurable.

## Managed identities

Pattern:

```text
id-cloudmart-<component>-training-eastus
```

CloudMart uses one user-assigned managed identity per deployable component:

```text
storefront
web-bff
catalog-service
cart-service
order-service
inventory-service
payment-service
notification-service
```
