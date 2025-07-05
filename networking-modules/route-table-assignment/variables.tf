variable "route_table_assignments" {
  description = "A map of route table assignments to subnets. Keys are assignment identifiers."
  type        = map(object({
    subnet_id      = string
    route_table_id = string
  }))
}