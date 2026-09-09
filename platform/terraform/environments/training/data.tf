module "postgresql" {
  count  = local.stage.postgresql_server ? 1 : 0
  source = "../../modules/postgresql"

  name                = local.resource_names.postgresql_server
  resource_group_name = module.resource_group[0].name
  location            = var.location

  administrator_login    = var.postgresql_administrator_login
  administrator_password = var.postgresql_administrator_password

  postgresql_version    = "16"
  sku_name              = var.postgresql_sku_name
  storage_mb            = 32768
  backup_retention_days = 7

  firewall_rules = local.postgresql_firewall_rules
  databases      = local.postgresql_databases

  tags = local.common_tags
}

module "managed_redis" {
  count  = local.stage.managed_redis ? 1 : 0
  source = "../../modules/managed-redis"

  name                = local.resource_names.managed_redis
  resource_group_name = module.resource_group[0].name
  location            = var.location

  sku_name                  = "Balanced_B0"
  high_availability_enabled = false
  public_network_access     = "Enabled"

  tags = local.common_tags
}
