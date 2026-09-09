variable "name" {
  description = "Azure Managed Redis resource name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing Managed Redis."
  type        = string
}

variable "location" {
  description = "Azure region for Managed Redis."
  type        = string
}

variable "sku_name" {
  description = "Managed Redis SKU."
  type        = string
  default     = "Balanced_B0"
}

variable "high_availability_enabled" {
  description = "Whether Managed Redis high availability is enabled."
  type        = bool
  default     = false
}

variable "public_network_access" {
  description = "Managed Redis public network access mode."
  type        = string
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "public_network_access must be Enabled or Disabled."
  }
}

variable "tags" {
  description = "Tags applied to Managed Redis."
  type        = map(string)
  default     = {}
}
