output "id" {
  description = "Container App resource ID."
  value       = azurerm_container_app.this.id
}

output "name" {
  description = "Container App resource name."
  value       = azurerm_container_app.this.name
}

output "fqdn" {
  description = "Container App ingress FQDN, or null when ingress is disabled."
  value       = var.ingress == null ? null : azurerm_container_app.this.ingress[0].fqdn
}

output "latest_revision_name" {
  description = "Latest Container App revision name."
  value       = azurerm_container_app.this.latest_revision_name
}

output "latest_revision_fqdn" {
  description = "Latest revision FQDN when available."
  value       = azurerm_container_app.this.latest_revision_fqdn
}
