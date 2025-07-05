variable "name" {}
variable "address_space" {
  type = list(string)
}
variable "location" {}
variable "resource_group_name" {}

variable "rg_id" {
  description = "The resource group ID, optionally passed for dependent resources."
  type        = string
  default     = null
}