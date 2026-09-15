# CloudMart Azure Cost Controls

## Budget

- Name: budget-cloudmart-training
- Scope: CloudMart-Azure-Training
- Period: monthly
- Amount: 100 USD or billing-currency equivalent

## Alerts

### Actual cost

- 50%: review usage
- 80%: investigate cost
- 100%: take action

### Forecast

- 80%: review projected usage

## Important

- Budget alerts do not stop Azure resources.
- Cost information can be delayed.
- Remove resources when they are no longer required.

## Standard tags

| Tag | Value |
|---|---|
| application | cloudmart |
| environment | training |
| managed-by | terraform |
| cost-center | training |

## Tag rules

- Apply common tags to supported CloudMart resources.
- Do not store secrets in tags.
- Do not assume resource-group tags automatically appear on resources.
