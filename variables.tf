variable "location" {
  description = "The Azure region where resources are deployed."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}
variable "resource_group_mode" {
  description = "Mode for handling the resource group. Use 'create' to create a new resource group, or 'import' to reference an existing one."
  type        = string
  default     = "create"
}
variable "vnet_configs" {
  description = "Configuration for Virtual Networks (VNets)."
  type = map(object({
    name          = string
    address_space = list(string)
  }))
}
variable "route_table_configs" {
  description = "Configuration for Route Tables, including their routes."
  type = map(object({
    name = string
    routes = list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string) # Changed from optional(string)
    }))
  }))
}

/*
variable "ip_groups" {
  description = "Definitions for Azure IP Groups and their CIDRs."
  type = map(object({
    name  = string
    cidrs = list(string)
  }))
}
*/
variable "nsg_configs" {
  description = "Configuration for Network Security Groups (NSGs) and their rules."
  type = map(object({
    name           = string
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_address_prefix      = string
      destination_address_prefix = optional(string)      # Single string (optional)
      destination_address_prefixes = optional(list(string)) # List of strings (optional)
      source_port_range          = string
      destination_port_range     = string
    }))
  }))
}

variable "assignments" {
  description = "Mapping of subnets to NSGs, Route Tables, and VNets."
  type = map(object({
    name             = string
    address_prefixes = list(string)
    vnet_name        = string
    route_table      = optional(string) # Name of the route table (null if none)
    nsg              = optional(string) # Name of the NSG (null if none)
  }))
}
