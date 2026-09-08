variable "name" {
  description = "Azure Container Apps managed environment name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that owns the Container Apps environment."
  type        = string
}

variable "location" {
  description = "Azure region for the Container Apps environment."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace used by the environment."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Container Apps environment."
  type        = map(string)
  default     = {}
}
