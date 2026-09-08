variable "identities" {
  description = "Map of stable CloudMart component keys to Azure managed identity names."
  type        = map(string)
}

variable "resource_group_name" {
  description = "Resource group containing the user-assigned managed identities."
  type        = string
}

variable "location" {
  description = "Azure region for the managed identities."
  type        = string
}

variable "tags" {
  description = "Tags applied to every managed identity."
  type        = map(string)
  default     = {}
}
