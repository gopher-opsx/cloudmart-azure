output "id" {
  description = "Event Hubs namespace resource ID."
  value       = azurerm_eventhub_namespace.this.id
}

output "name" {
  description = "Event Hubs namespace name."
  value       = azurerm_eventhub_namespace.this.name
}

output "kafka_broker" {
  description = "Kafka-compatible Event Hubs broker endpoint."
  value       = "${azurerm_eventhub_namespace.this.name}.servicebus.windows.net:9093"
}

output "event_hub_names" {
  description = "Created Event Hub stream names."
  value       = sort(keys(azurerm_eventhub.this))
}

output "application_authorization_rule_id" {
  description = "Scoped CloudMart Send+Listen authorization rule ID."
  value       = var.create_application_authorization_rule ? azurerm_eventhub_namespace_authorization_rule.applications[0].id : null
}

output "application_primary_connection_string" {
  description = "Scoped Event Hubs namespace connection string for the Kafka SASL PLAIN password."
  value       = var.create_application_authorization_rule ? azurerm_eventhub_namespace_authorization_rule.applications[0].primary_connection_string : null
  sensitive   = true
}
