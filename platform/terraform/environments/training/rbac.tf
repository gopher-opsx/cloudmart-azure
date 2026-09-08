# Lesson 27: allow the interactive course operator to publish images to ACR.
# Runtime workload identities and CI/CD identities are added in later lessons.
resource "azurerm_role_assignment" "acr_publisher" {
  scope                = module.container_registry.id
  role_definition_name = "AcrPush"
  principal_id         = var.publisher_object_id
}

# Lesson 37: every CloudMart workload may pull its private image from ACR.
resource "azurerm_role_assignment" "acr_pull" {
  for_each = module.managed_identities.principal_ids

  scope                = module.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}

# Lesson 37: only backend services that require protected runtime
# configuration may read secret values from Key Vault.
resource "azurerm_role_assignment" "key_vault_secret_reader" {
  for_each = local.secret_consumers

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"

  principal_id = module.managed_identities.principal_ids[each.key]
}

# Lesson 37: the interactive course operator may create, update, and
# delete training secrets, without receiving Key Vault administration.
resource "azurerm_role_assignment" "key_vault_secret_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.publisher_object_id
}
