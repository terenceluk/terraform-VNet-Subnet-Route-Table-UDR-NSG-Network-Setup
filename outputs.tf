output "resource_group_id" {
  description = "The ID of the resource group used by this deployment."
  value       = local.resource_group_id
}

output "resource_group_name" {
  description = "The name of the resource group used by this deployment."
  value       = var.resource_group_name
}

output "vnet_ids" {
  description = "Map of VNet IDs keyed by the vnet_configs map key."
  value       = { for key, vnet in module.vnets : key => vnet.id }
}

output "vnet_names" {
  description = "Map of VNet names keyed by the vnet_configs map key."
  value       = { for key, vnet in module.vnets : key => vnet.name }
}

output "vnet_address_spaces" {
  description = "Map of VNet address spaces keyed by the vnet_configs map key."
  value       = { for key, vnet in module.vnets : key => vnet.address_space }
}

output "subnet_ids" {
  description = "Map of subnet IDs keyed by the assignments map key."
  value       = { for key, subnet in module.subnets : key => subnet.id }
}

output "route_table_ids" {
  description = "Map of route table IDs keyed by the route_table_configs map key."
  value       = { for key, route_table in module.route_tables : key => route_table.id }
}

output "nsg_ids" {
  description = "Map of NSG IDs keyed by the nsg_configs map key."
  value       = { for key, nsg in module.nsgs : key => nsg.id }
}