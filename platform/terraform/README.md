# CloudMart Azure Terraform

CloudMart uses a small Azure CLI bootstrap for Terraform remote state and a Terraform root module for the training workload.

## Layout

```text
platform/terraform/
├── environments/
│   └── training/          # Root module used by the course
└── modules/
    └── resource-group/    # First reusable child module
```

The remote-state resource group and storage account deliberately live outside the workload state so `terraform destroy` can remove the CloudMart workload without deleting the state backend Terraform still needs.

## Local files

Commit only the examples:

- `terraform.tfvars.example`
- `training.azurerm.tfbackend.example`

Keep populated `terraform.tfvars` and `*.tfbackend` files local and untracked. Do not store passwords, tokens, connection strings, or other credentials in either file.

## Bootstrap remote state

From the repository root:

```bash
export TFSTATE_STORAGE_ACCOUNT="stcloudmarttf<unique-suffix>"
./scripts/bootstrap/create-tfstate.sh
```

Then copy and edit the backend example:

```bash
cd platform/terraform/environments/training
cp training.azurerm.tfbackend.example training.azurerm.tfbackend
cp terraform.tfvars.example terraform.tfvars
```

Set the active subscription for the AzureRM provider without writing it into source control:

```bash
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
```

Initialize and validate:

```bash
terraform fmt -recursive ../..
terraform init -backend-config=training.azurerm.tfbackend
terraform validate
terraform plan
```

Before a recorded Terraform lesson, confirm the Azure subscription and review the plan before applying changes.
