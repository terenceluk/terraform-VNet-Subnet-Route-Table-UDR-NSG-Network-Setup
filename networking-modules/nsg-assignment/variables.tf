variable "nsg_assignments" {
  description = "A map of NSG assignments for subnets. Keys are assignment identifiers."
  type = map(object({
    subnet_id = string
    nsg_id    = string
  }))
}