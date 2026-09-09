resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  version = var.postgresql_version

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku_name   = var.sku_name
  storage_mb = var.storage_mb

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false

  public_network_access_enabled = true

  authentication {
    password_auth_enabled         = true
    active_directory_auth_enabled = false
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = var.firewall_rules

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id

  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each = var.databases

  name      = each.value
  server_id = azurerm_postgresql_flexible_server.this.id

  charset   = "UTF8"
  collation = "en_US.utf8"
}
