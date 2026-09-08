output "id" {
  description = "Log Analytics workspace Azure resource ID."
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "Log Analytics workspace name."
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Log Analytics workspace/customer ID used by dependent Azure services."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}
