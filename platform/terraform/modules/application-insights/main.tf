resource "azurerm_application_insights" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  application_type = "web"
  workspace_id     = var.log_analytics_workspace_id

  sampling_percentage  = 100
  daily_data_cap_in_gb = var.daily_data_cap_in_gb

  local_authentication_enabled = true

  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = var.tags
}
