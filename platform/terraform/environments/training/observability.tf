resource "azapi_update_resource" "managed_opentelemetry" {
  count = local.stage.managed_otel_agent ? 1 : 0

  type        = "Microsoft.App/managedEnvironments@2024-10-02-preview"
  resource_id = module.container_apps_environment[0].id

  body = {
    properties = {
      appInsightsConfiguration = {
        connectionString = module.application_insights[0].connection_string
      }

      openTelemetryConfiguration = {
        tracesConfiguration = {
          destinations = ["appInsights"]
        }

        logsConfiguration = {
          destinations = ["appInsights"]
        }
      }
    }
  }

  ignore_missing_property = true
}

resource "azurerm_application_insights_workbook" "operations" {
  count = local.stage.operations_monitoring ? 1 : 0

  name                = "8f7d5db4-e760-4f92-b3f4-78f0f2b98211"
  resource_group_name = module.resource_group[0].name
  location            = var.location
  display_name        = "CloudMart Operations"

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## CloudMart Operations\nFocused training view for failures, latency, replicas, and recent platform events."
        }
        name = "title"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "ContainerAppConsoleLogs_CL | where TimeGenerated > ago(30m) | where Log_s has_any ('error','failed','timeout') | project TimeGenerated, ContainerAppName_s, RevisionName_s, Log_s | order by TimeGenerated desc"
          size         = 0
          title        = "Recent application failures"
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
        }
        name = "application-failures"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "ContainerAppSystemLogs_CL | where TimeGenerated > ago(30m) | project TimeGenerated, ContainerAppName_s, RevisionName_s, Reason_s, Log_s | order by TimeGenerated desc"
          size         = 0
          title        = "Recent Container Apps platform events"
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
        }
        name = "platform-events"
      }
    ]
    fallbackResourceIds = [module.log_analytics[0].id]
    isLocked            = false
  })

  tags = local.common_tags
}

resource "azurerm_monitor_action_group" "operations" {
  count = local.stage.operations_monitoring && var.operations_alert_email != null ? 1 : 0

  name                = "ag-cloudmart-training"
  resource_group_name = module.resource_group[0].name
  short_name          = "cloudmart"

  email_receiver {
    name                    = "course-operator"
    email_address           = var.operations_alert_email
    use_common_alert_schema = true
  }

  tags = local.common_tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "revision_failures" {
  count = local.stage.operations_monitoring ? 1 : 0

  name                = "cloudmart-revision-failures"
  resource_group_name = module.resource_group[0].name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [module.log_analytics[0].id]
  severity             = 2
  enabled              = true

  description = "CloudMart Container Apps revision or provisioning failures."

  criteria {
    query = <<-KQL
      ContainerAppSystemLogs_CL
      | where TimeGenerated > ago(5m)
      | where Log_s has_any ("Failed", "ImagePull", "BackOff", "Unhealthy")
         or Reason_s has_any ("Failed", "ImagePull", "BackOff", "Unhealthy")
    KQL

    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  dynamic "action" {
    for_each = var.operations_alert_email != null ? [1] : []

    content {
      action_groups = [azurerm_monitor_action_group.operations[0].id]
    }
  }

  tags = local.common_tags
}
