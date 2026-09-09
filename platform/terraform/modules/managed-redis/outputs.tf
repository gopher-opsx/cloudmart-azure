output "id" {
  description = "Managed Redis resource ID."
  value       = azurerm_managed_redis.this.id
}

output "name" {
  description = "Managed Redis resource name."
  value       = azurerm_managed_redis.this.name
}

output "hostname" {
  description = "Managed Redis endpoint hostname."
  value       = azurerm_managed_redis.this.hostname
}

output "port" {
  description = "Managed Redis encrypted endpoint port."
  value       = azurerm_managed_redis.this.default_database[0].port
}

output "primary_access_key" {
  description = "Managed Redis primary access key."
  value       = azurerm_managed_redis.this.default_database[0].primary_access_key
  sensitive   = true
}
