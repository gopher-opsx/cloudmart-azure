locals {
  postgres_database_urls = local.stage.postgresql_server && var.postgresql_administrator_password != null ? {
    catalog      = "postgres://${urlencode(var.postgresql_administrator_login)}:${urlencode(var.postgresql_administrator_password)}@${module.postgresql[0].fqdn}:5432/catalog_db?sslmode=require"
    order        = "postgres://${urlencode(var.postgresql_administrator_login)}:${urlencode(var.postgresql_administrator_password)}@${module.postgresql[0].fqdn}:5432/orders_db?sslmode=require"
    inventory    = "postgres://${urlencode(var.postgresql_administrator_login)}:${urlencode(var.postgresql_administrator_password)}@${module.postgresql[0].fqdn}:5432/inventory_db?sslmode=require"
    payment      = "postgres://${urlencode(var.postgresql_administrator_login)}:${urlencode(var.postgresql_administrator_password)}@${module.postgresql[0].fqdn}:5432/payments_db?sslmode=require"
    notification = "postgres://${urlencode(var.postgresql_administrator_login)}:${urlencode(var.postgresql_administrator_password)}@${module.postgresql[0].fqdn}:5432/notifications_db?sslmode=require"
  } : {}
}

resource "azurerm_key_vault_secret" "catalog_database_url" {
  count = local.stage.catalog_app ? 1 : 0

  name         = "catalog-database-url"
  value        = local.postgres_database_urls.catalog
  key_vault_id = module.key_vault[0].id
}

resource "azurerm_key_vault_secret" "redis_primary_access_key" {
  count = local.stage.cart_app ? 1 : 0

  name         = "cart-redis-password"
  value        = module.managed_redis[0].primary_access_key
  key_vault_id = module.key_vault[0].id
}

resource "azurerm_key_vault_secret" "order_database_url" {
  count = local.stage.order_app ? 1 : 0

  name         = "order-database-url"
  value        = local.postgres_database_urls.order
  key_vault_id = module.key_vault[0].id
}

resource "azurerm_key_vault_secret" "event_hubs_connection_string" {
  count = local.stage.order_app ? 1 : 0

  name         = "event-hubs-connection-string"
  value        = module.event_hubs[0].application_primary_connection_string
  key_vault_id = module.key_vault[0].id
}

resource "azurerm_key_vault_secret" "inventory_database_url" {
  count = local.stage.inventory_app ? 1 : 0

  name         = "inventory-database-url"
  value        = local.postgres_database_urls.inventory
  key_vault_id = module.key_vault[0].id
}

resource "azurerm_key_vault_secret" "payment_database_url" {
  count = local.stage.payment_app ? 1 : 0

  name         = "payment-database-url"
  value        = local.postgres_database_urls.payment
  key_vault_id = module.key_vault[0].id
}

resource "azurerm_key_vault_secret" "notification_database_url" {
  count = local.stage.notification_app ? 1 : 0

  name         = "notification-database-url"
  value        = local.postgres_database_urls.notification
  key_vault_id = module.key_vault[0].id
}
