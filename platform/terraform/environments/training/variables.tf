variable "project_name" {
  description = "CloudMart workload name."
  type        = string
  default     = "cloudmart"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "training"
}

variable "location" {
  description = "Primary Azure region."
  type        = string
  default     = "eastus"
}

variable "name_suffix" {
  description = "Short suffix used later for globally unique Azure resource names."
  type        = string
}

variable "owner" {
  description = "Non-sensitive owner label applied to Azure resource tags."
  type        = string
}

variable "publisher_object_id" {
  description = "Microsoft Entra object ID used for interactive image publication."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.publisher_object_id))
    error_message = "publisher_object_id must be a Microsoft Entra object ID in GUID format."
  }
}

variable "log_retention_in_days" {
  description = "Log Analytics retention period for the training environment."
  type        = number
  default     = 30
}

variable "log_daily_quota_gb" {
  description = "Log Analytics daily ingestion cap in GB for the training environment."
  type        = number
  default     = 1
}
