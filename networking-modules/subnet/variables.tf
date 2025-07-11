variable "name" {}
variable "address_prefixes" {
  type = list(string)
}
variable "resource_group_name" {}
variable "virtual_network_name" {}

variable "delegation" {
  description = "Optional delegation configuration for the subnet."
  type = object({
    name = string
    service_delegation = object({
      name = string
    })
  })
  default = null
}
