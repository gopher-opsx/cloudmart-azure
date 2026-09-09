variable "name" {
  description = "Container App resource name."
  type        = string
}

variable "container_name" {
  description = "Container name inside the Container App revision."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Container App."
  type        = string
}

variable "container_app_environment_id" {
  description = "Shared Container Apps Environment resource ID."
  type        = string
}

variable "image" {
  description = "Immutable ACR image reference, preferably repository@sha256:digest."
  type        = string
}

variable "identity_id" {
  description = "User-assigned managed identity resource ID used by the workload and ACR."
  type        = string
}

variable "registry_server" {
  description = "Private ACR login server."
  type        = string
}

variable "cpu" {
  description = "Container vCPU allocation."
  type        = number
}

variable "memory" {
  description = "Container memory allocation."
  type        = string
}

variable "min_replicas" {
  description = "Minimum replicas before later autoscaling lessons."
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum replicas before later autoscaling lessons."
  type        = number
  default     = 1
}

variable "environment_variables" {
  description = "Environment variables. Set exactly one of value or secret_name."
  type = map(object({
    value       = optional(string)
    secret_name = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for item in values(var.environment_variables) :
      (try(item.value, null) != null) != (try(item.secret_name, null) != null)
    ])
    error_message = "Each environment variable must set exactly one of value or secret_name."
  }
}

variable "key_vault_secrets" {
  description = "Container App secret name -> Key Vault secret ID."
  type        = map(string)
  default     = {}
}

variable "ingress" {
  description = "Ingress configuration. Use null for worker applications."
  type = object({
    external_enabled = bool
    target_port      = number
  })
  default  = null
  nullable = true
}

variable "probes_enabled" {
  description = "Enable the standardized CloudMart startup/liveness/readiness policy."
  type        = bool
  default     = false
}

variable "probe_port" {
  description = "Port used by health probes."
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Tags applied to the Container App."
  type        = map(string)
  default     = {}
}

variable "http_scale_rules" {
  description = "HTTP concurrency scaling rules."
  type = list(object({
    name                = string
    concurrent_requests = string
  }))
  default = []
}

variable "custom_scale_rules" {
  description = "KEDA-compatible custom scaling rules."
  type = list(object({
    name             = string
    custom_rule_type = string
    metadata         = map(string)
    authentication = optional(list(object({
      secret_name       = string
      trigger_parameter = string
    })), [])
  }))
  default = []
}

variable "polling_interval_in_seconds" {
  description = "KEDA polling interval."
  type        = number
  default     = 30
}

variable "cooldown_period_in_seconds" {
  description = "KEDA cooldown period."
  type        = number
  default     = 300
}

variable "revision_mode" {
  description = "Container Apps revision mode. Traffic splitting requires Multiple."
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be Single or Multiple."
  }
}
