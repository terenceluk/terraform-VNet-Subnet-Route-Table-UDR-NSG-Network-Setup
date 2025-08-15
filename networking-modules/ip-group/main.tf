resource "azurerm_ip_group" "ip_group" {
  for_each            = var.ip_groups
  name                = each.value.name
  cidrs               = each.value.cidrs
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
