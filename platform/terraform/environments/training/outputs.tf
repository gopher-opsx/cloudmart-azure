output "course_stage" {
  description = "Course lesson stage last applied to this Terraform state."
  value       = var.course_stage
}

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

output "postgresql" {
  description = "CloudMart PostgreSQL Flexible Server connection metadata."
  value = local.stage.postgresql_server ? {
    id                  = module.postgresql[0].id
    name                = module.postgresql[0].name
    fqdn                = module.postgresql[0].fqdn
    administrator_login = module.postgresql[0].administrator_login
  } : null
}

output "postgresql_database_names" {
  description = "CloudMart service-owned PostgreSQL databases."
  value       = local.stage.postgresql_databases ? module.postgresql[0].database_names : []
}

output "managed_redis" {
  description = "CloudMart Azure Managed Redis endpoint metadata."
  value = local.stage.managed_redis ? {
    id       = module.managed_redis[0].id
    name     = module.managed_redis[0].name
    hostname = module.managed_redis[0].hostname
    port     = module.managed_redis[0].port
  } : null
}

output "managed_redis_primary_access_key" {
  description = "Managed Redis primary access key used by the training Cart Service."
  value       = local.stage.managed_redis ? module.managed_redis[0].primary_access_key : null
  sensitive   = true
}

output "event_hubs" {
  description = "CloudMart Event Hubs namespace and Kafka-compatible endpoint metadata."
  value = local.stage.event_hubs_namespace ? {
    id              = module.event_hubs[0].id
    name            = module.event_hubs[0].name
    kafka_broker    = module.event_hubs[0].kafka_broker
    event_hub_names = module.event_hubs[0].event_hub_names
  } : null
}

output "event_hubs_application_connection_string" {
  description = "Scoped Send+Listen Event Hubs connection string used as the Kafka SASL PLAIN password."
  value       = local.stage.event_hubs_auth ? module.event_hubs[0].application_primary_connection_string : null
  sensitive   = true
}

output "backend_container_apps" {
  description = "CloudMart backend Container App names and ingress FQDNs."
  value = {
    catalog = local.stage.catalog_app ? {
      name = module.catalog_app[0].name
      fqdn = module.catalog_app[0].fqdn
    } : null

    cart = local.stage.cart_app ? {
      name = module.cart_app[0].name
      fqdn = module.cart_app[0].fqdn
    } : null

    order = local.stage.order_app ? {
      name = module.order_app[0].name
      fqdn = module.order_app[0].fqdn
    } : null

    inventory = local.stage.inventory_app ? {
      name = module.inventory_app[0].name
      fqdn = module.inventory_app[0].fqdn
    } : null

    payment = local.stage.payment_app ? {
      name = module.payment_app[0].name
      fqdn = module.payment_app[0].fqdn
    } : null

    notification = local.stage.notification_app ? {
      name = module.notification_app[0].name
      fqdn = module.notification_app[0].fqdn
    } : null
  }
}
