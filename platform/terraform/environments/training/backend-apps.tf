locals {
  backend_bootstrap_cpu    = 0.5
  backend_bootstrap_memory = "1Gi"

  backend_standard_cpu    = 0.25
  backend_standard_memory = "0.5Gi"

  backend_cpu = (
    local.stage.backend_runtime_policy
    ? local.backend_standard_cpu
    : local.backend_bootstrap_cpu
  )

  backend_memory = (
    local.stage.backend_runtime_policy
    ? local.backend_standard_memory
    : local.backend_bootstrap_memory
  )

  active_backend_image_keys = compact([
    local.stage.catalog_app ? "catalog-service" : "",
    local.stage.cart_app ? "cart-service" : "",
    local.stage.order_app ? "order-service" : "",
    local.stage.inventory_app ? "inventory-service" : "",
    local.stage.payment_app ? "payment-service" : "",
    local.stage.notification_app ? "notification-service" : "",
  ])
}

check "active_backend_images_are_immutable" {
  assert {
    condition = alltrue([
      for key in local.active_backend_image_keys :
      can(regex("@sha256:[0-9a-fA-F]{64}$", lookup(var.cloudmart_image_references, key, "")))
    ])
    error_message = "Every active backend app requires an immutable repository@sha256 image reference. Run scripts/terraform/render-release-tfvars.sh after Section 5."
  }
}

module "catalog_app" {
  count  = local.stage.catalog_app ? 1 : 0
  source = "../../modules/container-app"

  name                         = local.app_names.catalog
  container_name               = "catalog"
  resource_group_name          = module.resource_group[0].name
  container_app_environment_id = module.container_apps_environment[0].id

  image           = lookup(var.cloudmart_image_references, "catalog-service", "")
  identity_id     = module.managed_identities[0].ids["catalog-service"]
  registry_server = module.container_registry[0].login_server

  cpu    = local.backend_cpu
  memory = local.backend_memory

  environment_variables = {
    HTTP_ADDR = { value = ":8081" }
    DATABASE_URL = {
      secret_name = "database-url"
    }
  }

  key_vault_secrets = {
    database-url = azurerm_key_vault_secret.catalog_database_url[0].id
  }

  ingress = {
    external_enabled = false
    target_port      = 8081
  }

  probes_enabled = local.stage.backend_runtime_policy
  probe_port     = 8081

  tags = local.common_tags
}

module "cart_app" {
  count  = local.stage.cart_app ? 1 : 0
  source = "../../modules/container-app"

  name                         = local.app_names.cart
  container_name               = "cart"
  resource_group_name          = module.resource_group[0].name
  container_app_environment_id = module.container_apps_environment[0].id

  image           = lookup(var.cloudmart_image_references, "cart-service", "")
  identity_id     = module.managed_identities[0].ids["cart-service"]
  registry_server = module.container_registry[0].login_server

  cpu    = local.backend_cpu
  memory = local.backend_memory

  environment_variables = {
    HTTP_ADDR         = { value = ":8082" }
    REDIS_ADDR        = { value = "${module.managed_redis[0].hostname}:${module.managed_redis[0].port}" }
    REDIS_PASSWORD    = { secret_name = "redis-password" }
    REDIS_TLS_ENABLED = { value = "true" }
    REDIS_DB          = { value = "0" }
  }

  key_vault_secrets = {
    redis-password = azurerm_key_vault_secret.redis_primary_access_key[0].id
  }

  ingress = {
    external_enabled = false
    target_port      = 8082
  }

  probes_enabled = local.stage.backend_runtime_policy
  probe_port     = 8082

  tags = local.common_tags
}

module "order_app" {
  count  = local.stage.order_app ? 1 : 0
  source = "../../modules/container-app"

  name                         = local.app_names.order
  container_name               = "order"
  resource_group_name          = module.resource_group[0].name
  container_app_environment_id = module.container_apps_environment[0].id

  image           = lookup(var.cloudmart_image_references, "order-service", "")
  identity_id     = module.managed_identities[0].ids["order-service"]
  registry_server = module.container_registry[0].login_server

  cpu    = local.backend_cpu
  memory = local.backend_memory

  environment_variables = {
    HTTP_ADDR               = { value = ":8083" }
    DATABASE_URL            = { secret_name = "database-url" }
    KAFKA_BROKERS           = { value = module.event_hubs[0].kafka_broker }
    KAFKA_SECURITY_PROTOCOL = { value = "SASL_SSL" }
    KAFKA_SASL_MECHANISM    = { value = "PLAIN" }
    KAFKA_SASL_USERNAME     = { value = "$ConnectionString" }
    KAFKA_SASL_PASSWORD     = { secret_name = "event-hubs-connection" }
    ORDERS_TOPIC            = { value = "orders" }
    PAYMENTS_TOPIC          = { value = "payments" }
    PAYMENTS_CONSUMER_GROUP = { value = "order-service-payments" }
  }

  key_vault_secrets = {
    database-url          = azurerm_key_vault_secret.order_database_url[0].id
    event-hubs-connection = azurerm_key_vault_secret.event_hubs_connection_string[0].id
  }

  ingress = {
    external_enabled = false
    target_port      = 8083
  }

  probes_enabled = local.stage.backend_runtime_policy
  probe_port     = 8083

  tags = local.common_tags
}

module "inventory_app" {
  count  = local.stage.inventory_app ? 1 : 0
  source = "../../modules/container-app"

  name                         = local.app_names.inventory
  container_name               = "inventory"
  resource_group_name          = module.resource_group[0].name
  container_app_environment_id = module.container_apps_environment[0].id

  image           = lookup(var.cloudmart_image_references, "inventory-service", "")
  identity_id     = module.managed_identities[0].ids["inventory-service"]
  registry_server = module.container_registry[0].login_server

  cpu    = local.backend_cpu
  memory = local.backend_memory

  environment_variables = {
    HTTP_ADDR               = { value = ":8084" }
    DATABASE_URL            = { secret_name = "database-url" }
    KAFKA_BROKERS           = { value = module.event_hubs[0].kafka_broker }
    KAFKA_SECURITY_PROTOCOL = { value = "SASL_SSL" }
    KAFKA_SASL_MECHANISM    = { value = "PLAIN" }
    KAFKA_SASL_USERNAME     = { value = "$ConnectionString" }
    KAFKA_SASL_PASSWORD     = { secret_name = "event-hubs-connection" }
    ORDERS_TOPIC            = { value = "orders" }
    INVENTORY_TOPIC         = { value = "inventory" }
    KAFKA_CONSUMER_GROUP    = { value = "inventory-service" }
  }

  key_vault_secrets = {
    database-url          = azurerm_key_vault_secret.inventory_database_url[0].id
    event-hubs-connection = azurerm_key_vault_secret.event_hubs_connection_string[0].id
  }

  ingress = null

  probes_enabled = local.stage.backend_runtime_policy
  probe_port     = 8084

  tags = local.common_tags
}

module "payment_app" {
  count  = local.stage.payment_app ? 1 : 0
  source = "../../modules/container-app"

  name                         = local.app_names.payment
  container_name               = "payment"
  resource_group_name          = module.resource_group[0].name
  container_app_environment_id = module.container_apps_environment[0].id

  image           = lookup(var.cloudmart_image_references, "payment-service", "")
  identity_id     = module.managed_identities[0].ids["payment-service"]
  registry_server = module.container_registry[0].login_server

  cpu    = local.backend_cpu
  memory = local.backend_memory

  environment_variables = {
    HTTP_ADDR               = { value = ":8085" }
    DATABASE_URL            = { secret_name = "database-url" }
    KAFKA_BROKERS           = { value = module.event_hubs[0].kafka_broker }
    KAFKA_SECURITY_PROTOCOL = { value = "SASL_SSL" }
    KAFKA_SASL_MECHANISM    = { value = "PLAIN" }
    KAFKA_SASL_USERNAME     = { value = "$ConnectionString" }
    KAFKA_SASL_PASSWORD     = { secret_name = "event-hubs-connection" }
    INVENTORY_TOPIC         = { value = "inventory" }
    PAYMENTS_TOPIC          = { value = "payments" }
    KAFKA_CONSUMER_GROUP    = { value = "payment-service" }
    PAYMENT_MAX_AUTH_CENTS  = { value = "500000" }
  }

  key_vault_secrets = {
    database-url          = azurerm_key_vault_secret.payment_database_url[0].id
    event-hubs-connection = azurerm_key_vault_secret.event_hubs_connection_string[0].id
  }

  ingress = null

  probes_enabled = local.stage.backend_runtime_policy
  probe_port     = 8085

  tags = local.common_tags
}

module "notification_app" {
  count  = local.stage.notification_app ? 1 : 0
  source = "../../modules/container-app"

  name                         = local.app_names.notification
  container_name               = "notification"
  resource_group_name          = module.resource_group[0].name
  container_app_environment_id = module.container_apps_environment[0].id

  image           = lookup(var.cloudmart_image_references, "notification-service", "")
  identity_id     = module.managed_identities[0].ids["notification-service"]
  registry_server = module.container_registry[0].login_server

  cpu    = local.backend_cpu
  memory = local.backend_memory

  environment_variables = {
    HTTP_ADDR               = { value = ":8086" }
    DATABASE_URL            = { secret_name = "database-url" }
    KAFKA_BROKERS           = { value = module.event_hubs[0].kafka_broker }
    KAFKA_SECURITY_PROTOCOL = { value = "SASL_SSL" }
    KAFKA_SASL_MECHANISM    = { value = "PLAIN" }
    KAFKA_SASL_USERNAME     = { value = "$ConnectionString" }
    KAFKA_SASL_PASSWORD     = { secret_name = "event-hubs-connection" }
    ORDERS_TOPIC            = { value = "orders" }
    KAFKA_CONSUMER_GROUP    = { value = "notification-service-v1" }
  }

  key_vault_secrets = {
    database-url          = azurerm_key_vault_secret.notification_database_url[0].id
    event-hubs-connection = azurerm_key_vault_secret.event_hubs_connection_string[0].id
  }

  ingress = null

  probes_enabled = local.stage.backend_runtime_policy
  probe_port     = 8086

  tags = local.common_tags
}
