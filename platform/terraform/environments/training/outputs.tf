output "deployment_context" {
  description = "Shared CloudMart training deployment context."
  value = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
  }
}

output "resource_group_name" {
  description = "CloudMart workload resource group name."
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "CloudMart workload resource group resource ID."
  value       = module.resource_group.id
}

output "container_registry" {
  description = "CloudMart Azure Container Registry details used by image-release lessons."
  value = {
    id           = module.container_registry.id
    name         = module.container_registry.name
    login_server = module.container_registry.login_server
  }
}

output "log_analytics" {
  description = "Shared Log Analytics workspace details used by the Container Apps platform."
  value = {
    id           = module.log_analytics.id
    name         = module.log_analytics.name
    workspace_id = module.log_analytics.workspace_id
  }
}

output "container_apps_environment" {
  description = "Shared Azure Container Apps environment used by CloudMart workloads."
  value = {
    id             = module.container_apps_environment.id
    name           = module.container_apps_environment.name
    default_domain = module.container_apps_environment.default_domain
  }
}

output "application_insights" {
  description = "Workspace-based Application Insights resource linked to CloudMart Log Analytics."
  value = {
    id   = module.application_insights.id
    name = module.application_insights.name
  }
}

output "application_insights_connection_string" {
  description = "Application Insights connection string used later by CloudMart telemetry configuration."
  value       = module.application_insights.connection_string
  sensitive   = true
}

output "key_vault" {
  description = "CloudMart training Key Vault."
  value = {
    id        = module.key_vault.id
    name      = module.key_vault.name
    vault_uri = module.key_vault.vault_uri
  }
}

output "managed_identity_ids" {
  description = "User-assigned managed identity resource IDs keyed by CloudMart component."
  value       = module.managed_identities.ids
}

output "managed_identity_client_ids" {
  description = "User-assigned managed identity client IDs keyed by CloudMart component."
  value       = module.managed_identities.client_ids
}

output "managed_identity_principal_ids" {
  description = "User-assigned managed identity principal IDs keyed by CloudMart component."
  value       = module.managed_identities.principal_ids
}

output "managed_identity_names" {
  description = "User-assigned managed identity names keyed by CloudMart component."
  value       = module.managed_identities.names
}
