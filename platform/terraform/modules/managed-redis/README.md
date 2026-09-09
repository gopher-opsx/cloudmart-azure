# Azure Managed Redis module

Creates the training Redis service used by the CloudMart Cart Service.

Training baseline:

- SKU: `Balanced_B0`
- High availability: disabled
- Public network access: enabled
- Client protocol: encrypted
- Clustering policy: EnterpriseCluster
- Eviction policy: VolatileLRU
- Access-key authentication: enabled

Access-key authentication is a course compatibility choice because the supplied
Cart Service already supports a password + TLS configuration contract. Later
production designs can replace this with an identity-based authentication
model where appropriate.
