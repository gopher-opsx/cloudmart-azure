variable "name" {
  description = "Azure resource group name."
  type        = string
}

variable "location" {
  description = "Azure location."
  type        = string
}

variable "tags" {
  description = "Tags applied to the resource group."
  type        = map(string)
}
