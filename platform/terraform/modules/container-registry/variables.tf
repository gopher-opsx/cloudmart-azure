variable "name" {
  description = "Azure Container Registry name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the registry."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to the registry."
  type        = map(string)
  default     = {}
}
