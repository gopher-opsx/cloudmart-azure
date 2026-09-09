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

variable "course_stage" {
  description = "Current course lesson used to progressively enable CloudMart Azure resources while keeping the complete Terraform code on main."
  type        = number
  default     = 22

  validation {
    condition     = var.course_stage >= 22 && var.course_stage <= 95
    error_message = "course_stage must be between Lesson 22 and Lesson 95."
  }
}

variable "postgresql_administrator_login" {
  description = "PostgreSQL administrator login used for controlled training setup tasks."
  type        = string
  default     = "cloudmartadmin"
}

variable "postgresql_administrator_password" {
  description = "PostgreSQL administrator password. Supply with TF_VAR_postgresql_administrator_password; never commit it."
  type        = string
  sensitive   = true
  default     = null
  nullable    = true
}

variable "postgresql_sku_name" {
  description = "Training PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_admin_client_ipv4" {
  description = "Current public IPv4 address allowed to administer PostgreSQL. Keep this value in ignored terraform.tfvars."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.postgresql_admin_client_ipv4 == null ||
      can(cidrhost("${var.postgresql_admin_client_ipv4}/32", 0))
    )
    error_message = "postgresql_admin_client_ipv4 must be a valid IPv4 address."
  }
}

variable "cloudmart_image_references" {
  description = "Immutable CloudMart image references keyed by release-manifest component name."
  type        = map(string)
  default     = {}
}

variable "operations_alert_email" {
  description = "Optional email receiver for the Lesson 77 operations action group. Leave null to create the alert without email notification."
  type        = string
  default     = null
  nullable    = true
}

variable "troubleshooting_order_image" {
  description = "Optional intentionally bad Order image used only by Lesson 79."
  type        = string
  default     = null
  nullable    = true
}

variable "troubleshooting_catalog_db_failure" {
  description = "Enable the controlled Catalog database-connectivity failure used by Lesson 80."
  type        = bool
  default     = false
}

variable "troubleshooting_inventory_kafka_failure" {
  description = "Enable the controlled Inventory Event Hubs authentication failure used by Lesson 80."
  type        = bool
  default     = false
}
