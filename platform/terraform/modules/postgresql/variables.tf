variable "name" {
  description = "PostgreSQL Flexible Server name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing PostgreSQL."
  type        = string
}

variable "location" {
  description = "Azure region for PostgreSQL."
  type        = string
}

variable "administrator_login" {
  description = "PostgreSQL administrator login."
  type        = string
}

variable "administrator_password" {
  description = "PostgreSQL administrator password."
  type        = string
  sensitive   = true
}

variable "postgresql_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server compute SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "PostgreSQL storage in MiB."
  type        = number
  default     = 32768
}

variable "backup_retention_days" {
  description = "Backup retention period."
  type        = number
  default     = 7
}

variable "firewall_rules" {
  description = "PostgreSQL public-access firewall rules."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "databases" {
  description = "Service-owned PostgreSQL databases."
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to PostgreSQL."
  type        = map(string)
  default     = {}
}
