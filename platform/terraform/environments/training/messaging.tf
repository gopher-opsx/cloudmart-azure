module "event_hubs" {
  count  = local.stage.event_hubs_namespace ? 1 : 0
  source = "../../modules/event-hubs"

  name                = local.resource_names.event_hubs_namespace
  resource_group_name = module.resource_group[0].name
  location            = var.location

  sku      = "Standard"
  capacity = 1

  event_hubs = local.event_hubs

  create_application_authorization_rule = local.stage.event_hubs_auth
  application_authorization_rule_name   = "cloudmart-applications"

  tags = local.common_tags
}
