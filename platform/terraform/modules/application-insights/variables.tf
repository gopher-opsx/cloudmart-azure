variable "name" {
  description = "Application Insights resource name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing Application Insights."
  type        = string
}

variable "location" {
  description = "Azure region for Application Insights."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the existing Log Analytics workspace."
  type        = string
}

variable "daily_data_cap_in_gb" {
  description = "Daily ingestion cap for the training Application Insights resource."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags applied to Application Insights."
  type        = map(string)
  default     = {}
}
