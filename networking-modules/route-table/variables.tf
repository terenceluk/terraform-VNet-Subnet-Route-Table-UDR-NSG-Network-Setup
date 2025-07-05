variable "name" {
  description = "The name of the Route Table."
  type        = string
}

variable "location" {
  description = "The Azure region where the Route Table will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group."
  type        = string
}

variable "routes" {
  description = "A list of routes for the Route Table."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  validation {
    condition = alltrue([
      for r in var.routes :
      r.next_hop_type != "VirtualAppliance" || r.next_hop_in_ip_address != null
    ])
    error_message = "next_hop_in_ip_address must be defined for routes with next_hop_type 'VirtualAppliance'."
  }
}