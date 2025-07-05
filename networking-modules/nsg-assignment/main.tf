resource "azurerm_subnet_network_security_group_association" "nsg_assignment" {
  for_each                 = var.nsg_assignments
  subnet_id                = each.value.subnet_id
  network_security_group_id = each.value.nsg_id
}