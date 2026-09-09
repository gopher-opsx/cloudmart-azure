resource "azurerm_container_app" "this" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name

  revision_mode = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  registry {
    server   = var.registry_server
    identity = var.identity_id
  }

  dynamic "secret" {
    for_each = var.key_vault_secrets

    content {
      name                = secret.key
      identity            = var.identity_id
      key_vault_secret_id = secret.value
    }
  }

  dynamic "ingress" {
    for_each = var.ingress == null ? [] : [var.ingress]

    content {
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      transport                  = "auto"
      allow_insecure_connections = false

      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.environment_variables

        content {
          name        = env.key
          value       = try(env.value.value, null)
          secret_name = try(env.value.secret_name, null)
        }
      }

      dynamic "startup_probe" {
        for_each = var.probes_enabled ? [1] : []

        content {
          transport               = "HTTP"
          port                    = var.probe_port
          path                    = "/healthz"
          initial_delay           = 1
          interval_seconds        = 5
          timeout                 = 2
          failure_count_threshold = 30
        }
      }

      dynamic "liveness_probe" {
        for_each = var.probes_enabled ? [1] : []

        content {
          transport               = "HTTP"
          port                    = var.probe_port
          path                    = "/healthz"
          initial_delay           = 5
          interval_seconds        = 10
          timeout                 = 2
          failure_count_threshold = 3
        }
      }

      dynamic "readiness_probe" {
        for_each = var.probes_enabled ? [1] : []

        content {
          transport               = "HTTP"
          port                    = var.probe_port
          path                    = "/readyz"
          initial_delay           = 2
          interval_seconds        = 5
          timeout                 = 2
          failure_count_threshold = 6
          success_count_threshold = 1
        }
      }
    }
  }

  tags = var.tags
}
