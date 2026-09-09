locals {
  web_bff_catalog_url = "http://${local.app_names.catalog}"
  web_bff_cart_url    = "http://${local.app_names.cart}"
  web_bff_order_url   = "http://${local.app_names.order}"

  storefront_bff_upstream = "http://${local.app_names.web_bff}"
}

module "web_bff_app" {
  count  = local.stage.web_bff_app ? 1 : 0
  source = "../../modules/container-app"

  name                         = local.app_names.web_bff
  container_name               = "web-bff"
  resource_group_name          = module.resource_group[0].name
  container_app_environment_id = module.container_apps_environment[0].id

  image           = lookup(var.cloudmart_image_references, "web-bff", "")
  identity_id     = module.managed_identities[0].ids["web-bff"]
  registry_server = module.container_registry[0].login_server

  cpu    = 0.25
  memory = "0.5Gi"

  environment_variables = {
    HTTP_ADDR           = { value = ":8080" }
    CATALOG_SERVICE_URL = { value = local.web_bff_catalog_url }
    CART_SERVICE_URL    = { value = local.web_bff_cart_url }
    ORDER_SERVICE_URL   = { value = local.web_bff_order_url }

    # Browser traffic stays same-origin through Storefront /api.
    # This is intentionally not a wildcard CORS policy.
    ALLOWED_ORIGIN = { value = "http://localhost:4200" }
  }

  ingress = {
    external_enabled = false
    target_port      = 8080
  }

  probes_enabled = true
  probe_port     = 8080

  tags = local.common_tags
}

module "storefront_app" {
  count  = local.stage.storefront_app ? 1 : 0
  source = "../../modules/container-app"

  name                         = local.app_names.storefront
  container_name               = "storefront"
  resource_group_name          = module.resource_group[0].name
  container_app_environment_id = module.container_apps_environment[0].id

  image           = lookup(var.cloudmart_image_references, "storefront", "")
  identity_id     = module.managed_identities[0].ids["storefront"]
  registry_server = module.container_registry[0].login_server

  cpu    = 0.25
  memory = "0.5Gi"

  environment_variables = {
    BFF_UPSTREAM = { value = local.storefront_bff_upstream }
  }

  ingress = {
    external_enabled = true
    target_port      = 80
  }

  probes_enabled = true
  probe_port     = 80

  tags = local.common_tags
}
