module "resource_group" {
  source = "../../modules/resource-group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "container_registry" {
  source = "../../modules/container-registry"

  name                = local.resource_names.container_registry
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
}

module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = local.resource_names.log_analytics_workspace
  resource_group_name = module.resource_group.name
  location            = var.location

  retention_in_days = var.log_retention_in_days
  daily_quota_gb    = var.log_daily_quota_gb

  tags = local.common_tags
}

module "container_apps_environment" {
  source = "../../modules/container-apps-environment"

  name                = local.resource_names.container_apps_environment
  resource_group_name = module.resource_group.name
  location            = var.location

  log_analytics_workspace_id = module.log_analytics.id

  tags = local.common_tags
}

module "application_insights" {
  source = "../../modules/application-insights"

  name                = local.resource_names.application_insights
  resource_group_name = module.resource_group.name
  location            = var.location

  log_analytics_workspace_id = module.log_analytics.id
  daily_data_cap_in_gb       = 1

  tags = local.common_tags
}

data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "../../modules/key-vault"

  name                = local.resource_names.key_vault
  resource_group_name = module.resource_group.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  tags = local.common_tags
}

module "managed_identities" {
  source = "../../modules/managed-identities"

  identities          = local.managed_identity_names
  resource_group_name = module.resource_group.name
  location            = var.location

  tags = local.common_tags
}
