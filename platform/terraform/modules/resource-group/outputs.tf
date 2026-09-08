output "id" {
  description = "Azure resource group resource ID."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Azure resource group name."
  value       = azurerm_resource_group.this.name
}
