# Lesson 27: allow the interactive course operator to publish images to ACR.
resource "azurerm_role_assignment" "acr_publisher" {
  count = local.stage.acr_publisher ? 1 : 0

  scope                = module.container_registry[0].id
  role_definition_name = "AcrPush"
  principal_id         = var.publisher_object_id
}

# Lesson 37: every CloudMart workload may pull its private image from ACR.
resource "azurerm_role_assignment" "acr_pull" {
  for_each = local.stage.workload_rbac ? module.managed_identities[0].principal_ids : {}

  scope                = module.container_registry[0].id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}

# Lesson 37: only backend services that require protected runtime
# configuration may read secret values from Key Vault.
resource "azurerm_role_assignment" "key_vault_secret_reader" {
  for_each = local.stage.workload_rbac ? local.secret_consumers : toset([])

  scope                = module.key_vault[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identities[0].principal_ids[each.key]
}

# Lesson 37: the interactive course operator may manage training secrets.
resource "azurerm_role_assignment" "key_vault_secret_officer" {
  count = local.stage.workload_rbac ? 1 : 0

  scope                = module.key_vault[0].id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.publisher_object_id
}
