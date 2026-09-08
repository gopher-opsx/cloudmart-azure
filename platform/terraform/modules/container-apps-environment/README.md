# Container Apps Environment module

Creates the shared Azure Container Apps managed environment used by CloudMart.

Training baseline:

- Workload profiles environment
- Built-in `Consumption` workload profile
- Log Analytics integration
- Public network access enabled at the environment boundary
- No custom VNet
- Zone redundancy disabled

Ingress is configured later on each individual Container App. Creating this environment does not make CloudMart workloads public.
