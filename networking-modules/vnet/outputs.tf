output "id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.vnet.name
}

output "address_space" {
  description = "The address space(s) of the virtual network."
  value       = azurerm_virtual_network.vnet.address_space
}