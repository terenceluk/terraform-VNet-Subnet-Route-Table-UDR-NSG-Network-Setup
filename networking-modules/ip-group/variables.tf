variable "ip_groups" {
  description = "A map of IP Groups to be created. Keys are IP Group identifiers."
  type = map(object({
    name  = string
    cidrs = list(string)
  }))
}

variable "location" {
  description = "Azure location where the IP Groups will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the IP Groups will be created."
  type        = string
}