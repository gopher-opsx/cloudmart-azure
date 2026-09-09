variable "name" {
  description = "Event Hubs namespace name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing Event Hubs."
  type        = string
}

variable "location" {
  description = "Azure region for Event Hubs."
  type        = string
}

variable "sku" {
  description = "Event Hubs namespace SKU."
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Event Hubs namespace throughput units."
  type        = number
  default     = 1
}

variable "event_hubs" {
  description = "CloudMart Event Hubs keyed by Kafka-compatible stream name."
  type = map(object({
    partition_count         = number
    retention_time_in_hours = number
  }))
  default = {}
}

variable "create_application_authorization_rule" {
  description = "Create the scoped Send+Listen SAS rule used by the training Kafka clients."
  type        = bool
  default     = false
}

variable "application_authorization_rule_name" {
  description = "Name of the scoped application SAS rule."
  type        = string
  default     = "cloudmart-applications"
}

variable "tags" {
  description = "Tags applied to the namespace."
  type        = map(string)
  default     = {}
}
