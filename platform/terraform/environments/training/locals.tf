locals {
  name_base         = "${var.project_name}-${var.environment}"
  environment_short = var.environment == "training" ? "trn" : substr(var.environment, 0, 3)
  short_name_base   = "${var.project_name}-${local.environment_short}"

  resource_group_name = "rg-${local.name_base}-${var.location}"

  resource_names = {
    container_registry         = lower("acr${replace(var.project_name, "-", "")}${replace(var.environment, "-", "")}${var.name_suffix}")
    log_analytics_workspace    = "log-${local.name_base}-${var.location}"
    container_apps_environment = "cae-${local.name_base}-${var.location}"
    application_insights       = "appi-${local.name_base}-${var.location}"
    key_vault                  = lower("kv-${substr(replace(var.project_name, "-", ""), 0, 8)}-${substr(replace(var.environment, "-", ""), 0, 5)}-${var.name_suffix}")
    postgresql_server          = lower("psql-${local.short_name_base}-${var.name_suffix}")
    managed_redis              = lower("redis-${local.short_name_base}-${var.name_suffix}")
    event_hubs_namespace       = lower("evhns-${local.short_name_base}-${var.name_suffix}")
  }

  common_tags = {
    application = var.project_name
    environment = var.environment
    managed-by  = "terraform"
    cost-center = "training"
    owner       = var.owner
  }

  app_names = {
    storefront   = "ca-storefront-${var.environment}"
    web_bff      = "ca-web-bff-${var.environment}"
    catalog      = "ca-catalog-${var.environment}"
    cart         = "ca-cart-${var.environment}"
    order        = "ca-order-${var.environment}"
    inventory    = "ca-inventory-${var.environment}"
    payment      = "ca-payment-${var.environment}"
    notification = "ca-notification-${var.environment}"
  }

  managed_identity_names = {
    storefront           = "id-cloudmart-storefront-${var.environment}-${var.location}"
    web-bff              = "id-cloudmart-web-bff-${var.environment}-${var.location}"
    catalog-service      = "id-cloudmart-catalog-${var.environment}-${var.location}"
    cart-service         = "id-cloudmart-cart-${var.environment}-${var.location}"
    order-service        = "id-cloudmart-order-${var.environment}-${var.location}"
    inventory-service    = "id-cloudmart-inventory-${var.environment}-${var.location}"
    payment-service      = "id-cloudmart-payment-${var.environment}-${var.location}"
    notification-service = "id-cloudmart-notification-${var.environment}-${var.location}"
  }

  secret_consumers = toset([
    "catalog-service",
    "cart-service",
    "order-service",
    "inventory-service",
    "payment-service",
    "notification-service",
  ])


  postgresql_firewall_rules = (
    local.stage.postgresql_firewall && var.postgresql_admin_client_ipv4 != null
    ? {
      admin-client = {
        start_ip_address = var.postgresql_admin_client_ipv4
        end_ip_address   = var.postgresql_admin_client_ipv4
      }
    }
    : {}
  )

  postgresql_databases = local.stage.postgresql_databases ? toset([
    "catalog_db",
    "orders_db",
    "inventory_db",
    "payments_db",
    "notifications_db",
  ]) : toset([])


  event_hubs = local.stage.event_hubs ? {
    orders = {
      partition_count         = 3
      retention_time_in_hours = 24
    }

    inventory = {
      partition_count         = 3
      retention_time_in_hours = 24
    }

    payments = {
      partition_count         = 3
      retention_time_in_hours = 24
    }
  } : {}

  kafka_consumers = {
    inventory_service = {
      event_hub = "orders"
      group_id  = "inventory-service"
    }

    notification_service = {
      event_hub = "orders"
      group_id  = "notification-service-v1"
    }

    payment_service = {
      event_hub = "inventory"
      group_id  = "payment-service"
    }

    order_service_payments = {
      event_hub = "payments"
      group_id  = "order-service-payments"
    }
  }

  # The complete course configuration lives on main. These gates make a
  # lesson-specific tfvars file activate only the infrastructure introduced
  # up to that point in the course.
  stage = {
    resource_group                = var.course_stage >= 23
    container_registry            = var.course_stage >= 26
    acr_publisher                 = var.course_stage >= 27
    log_analytics                 = var.course_stage >= 32
    container_apps_environment    = var.course_stage >= 33
    application_insights          = var.course_stage >= 34
    key_vault                     = var.course_stage >= 35
    managed_identities            = var.course_stage >= 36
    workload_rbac                 = var.course_stage >= 37
    postgresql_server             = var.course_stage >= 39
    postgresql_firewall           = var.course_stage >= 40
    postgresql_databases          = var.course_stage >= 41
    managed_redis                 = var.course_stage >= 43
    event_hubs_namespace          = var.course_stage >= 47
    event_hubs                    = var.course_stage >= 48
    event_hubs_auth               = var.course_stage >= 50
    backend_apps_foundation       = var.course_stage >= 53
    postgresql_runtime_access     = var.course_stage >= 54
    catalog_app                   = var.course_stage >= 54
    cart_app                      = var.course_stage >= 55
    order_app                     = var.course_stage >= 56
    inventory_app                 = var.course_stage >= 57
    payment_app                   = var.course_stage >= 58
    notification_app              = var.course_stage >= 59
    backend_runtime_policy        = var.course_stage >= 60
    web_bff_app                   = var.course_stage >= 62
    storefront_app                = var.course_stage >= 64
    edge_policy_verified          = var.course_stage >= 65
    security_hardening_checkpoint = var.course_stage >= 67
  }
}
