output "deployment_context" {
  description = "Shared CloudMart training deployment context."
  value = {
    project      = var.project_name
    environment  = var.environment
    location     = var.location
    course_stage = var.course_stage
  }
}

output "resource_group_name" {
  description = "CloudMart workload resource group name."
  value       = local.stage.resource_group ? module.resource_group[0].name : null
}

output "resource_group_id" {
  description = "CloudMart workload resource group resource ID."
  value       = local.stage.resource_group ? module.resource_group[0].id : null
}

output "container_registry" {
  description = "CloudMart Azure Container Registry details used by image-release lessons."
  value = local.stage.container_registry ? {
    id           = module.container_registry[0].id
    name         = module.container_registry[0].name
    login_server = module.container_registry[0].login_server
  } : null
}

output "container_registry_name" {
  description = "ACR name for recording and helper scripts."
  value       = local.stage.container_registry ? module.container_registry[0].name : null
}

output "log_analytics" {
  description = "Shared Log Analytics workspace details used by the Container Apps platform."
  value = local.stage.log_analytics ? {
    id           = module.log_analytics[0].id
    name         = module.log_analytics[0].name
    workspace_id = module.log_analytics[0].workspace_id
  } : null
}

output "container_apps_environment" {
  description = "Shared Azure Container Apps environment used by CloudMart workloads."
  value = local.stage.container_apps_environment ? {
    id             = module.container_apps_environment[0].id
    name           = module.container_apps_environment[0].name
    default_domain = module.container_apps_environment[0].default_domain
  } : null
}

output "application_insights" {
  description = "Workspace-based Application Insights resource linked to CloudMart Log Analytics."
  value = local.stage.application_insights ? {
    id   = module.application_insights[0].id
    name = module.application_insights[0].name
  } : null
}

output "application_insights_connection_string" {
  description = "Application Insights connection string used later by CloudMart telemetry configuration."
  value       = local.stage.application_insights ? module.application_insights[0].connection_string : null
  sensitive   = true
}

output "key_vault" {
  description = "CloudMart training Key Vault."
  value = local.stage.key_vault ? {
    id        = module.key_vault[0].id
    name      = module.key_vault[0].name
    vault_uri = module.key_vault[0].vault_uri
  } : null
}

output "managed_identity_ids" {
  description = "User-assigned managed identity resource IDs keyed by CloudMart component."
  value       = local.stage.managed_identities ? module.managed_identities[0].ids : {}
}

output "managed_identity_client_ids" {
  description = "User-assigned managed identity client IDs keyed by CloudMart component."
  value       = local.stage.managed_identities ? module.managed_identities[0].client_ids : {}
}

output "managed_identity_principal_ids" {
  description = "User-assigned managed identity principal IDs keyed by CloudMart component."
  value       = local.stage.managed_identities ? module.managed_identities[0].principal_ids : {}
}

output "managed_identity_names" {
  description = "User-assigned managed identity names keyed by CloudMart component."
  value       = local.stage.managed_identities ? module.managed_identities[0].names : {}
}
