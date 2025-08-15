variable "name" {
  description = "The name of the NSG."
  type        = string
}

variable "location" {
  description = "The Azure region where the NSG will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "security_rules" {
  description = "A list of security rules for the NSG."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    destination_port_range     = string
    source_port_range          = string
    destination_address_prefix = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
}

variable "tags" {
  description = "A map of tags to apply to the NSG."
  type        = map(string)
  default     = {}
}
