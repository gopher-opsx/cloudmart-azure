resource "azurerm_eventhub_namespace" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku      = var.sku
  capacity = var.capacity

  auto_inflate_enabled          = false
  local_authentication_enabled  = true
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"

  tags = var.tags
}

resource "azurerm_eventhub" "this" {
  for_each = var.event_hubs

  name         = each.key
  namespace_id = azurerm_eventhub_namespace.this.id

  partition_count = each.value.partition_count

  retention_description {
    cleanup_policy          = "Delete"
    retention_time_in_hours = each.value.retention_time_in_hours
  }
}

resource "azurerm_eventhub_namespace_authorization_rule" "applications" {
  count = var.create_application_authorization_rule ? 1 : 0

  name                = var.application_authorization_rule_name
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name

  listen = true
  send   = true
  manage = false
}
