locals {
  name_base = "${var.project_name}-${var.environment}"

  resource_group_name = "rg-${local.name_base}-${var.location}"

  # Some Azure resources, including ACR, have global naming constraints and
  # cannot contain hyphens. name_suffix keeps the training deployment unique.
  resource_names = {
    container_registry          = lower("acr${replace(var.project_name, "-", "")}${replace(var.environment, "-", "")}${var.name_suffix}")
    log_analytics_workspace     = "log-${local.name_base}-${var.location}"
    container_apps_environment = "cae-${local.name_base}-${var.location}"
    application_insights       = "appi-${local.name_base}-${var.location}"
    key_vault                  = lower("kv-${substr(replace(var.project_name, "-", ""), 0, 8)}-${substr(replace(var.environment, "-", ""), 0, 5)}-${var.name_suffix}")
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
  "storefront" =
    "id-cloudmart-storefront-${var.environment}-${var.location}"

  "web-bff" =
    "id-cloudmart-web-bff-${var.environment}-${var.location}"

  "catalog-service" =
    "id-cloudmart-catalog-${var.environment}-${var.location}"

  "cart-service" =
    "id-cloudmart-cart-${var.environment}-${var.location}"

  "order-service" =
    "id-cloudmart-order-${var.environment}-${var.location}"

  "inventory-service" =
    "id-cloudmart-inventory-${var.environment}-${var.location}"

  "payment-service" =
    "id-cloudmart-payment-${var.environment}-${var.location}"

  "notification-service" =
    "id-cloudmart-notification-${var.environment}-${var.location}"
}

secret_consumers = toset([
  "catalog-service",
  "cart-service",
  "order-service",
  "inventory-service",
  "payment-service",
  "notification-service",
])
}
