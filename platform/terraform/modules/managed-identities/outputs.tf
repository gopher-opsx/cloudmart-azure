output "ids" {
  description = "Managed identity resource IDs keyed by CloudMart component."
  value = {
    for key, identity in azurerm_user_assigned_identity.this :
    key => identity.id
  }
}

output "client_ids" {
  description = "Managed identity client IDs keyed by CloudMart component."
  value = {
    for key, identity in azurerm_user_assigned_identity.this :
    key => identity.client_id
  }
}

output "principal_ids" {
  description = "Microsoft Entra principal IDs keyed by CloudMart component."
  value = {
    for key, identity in azurerm_user_assigned_identity.this :
    key => identity.principal_id
  }
}

output "names" {
  description = "Managed identity Azure resource names keyed by CloudMart component."
  value = {
    for key, identity in azurerm_user_assigned_identity.this :
    key => identity.name
  }
}
