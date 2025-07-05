output "nsg_assignment_ids" {
  description = "List of NSG assignment resource IDs."
  value       = [for assignment in azurerm_subnet_network_security_group_association.nsg_assignment : assignment.id]
}