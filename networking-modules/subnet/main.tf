resource "azurerm_subnet" "subnet" {
  name                 = var.name
  address_prefixes     = var.address_prefixes
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  dynamic "delegation" {
    for_each = var.delegation != null ? [var.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name = delegation.value.service_delegation.name
      }
    }
  }
}
