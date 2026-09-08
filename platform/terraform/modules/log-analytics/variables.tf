variable "name" {
  description = "Log Analytics workspace name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that owns the workspace."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string
}

variable "retention_in_days" {
  description = "Workspace log retention period in days."
  type        = number

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion cap in gigabytes. Use -1 for no cap."
  type        = number

  validation {
    condition     = var.daily_quota_gb == -1 || var.daily_quota_gb > 0
    error_message = "daily_quota_gb must be -1 (no cap) or greater than 0."
  }
}

variable "tags" {
  description = "Common tags applied to the workspace."
  type        = map(string)
  default     = {}
}
