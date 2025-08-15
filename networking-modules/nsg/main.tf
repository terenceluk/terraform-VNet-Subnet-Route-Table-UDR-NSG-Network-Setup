resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_address_prefix      = security_rule.value.source_address_prefix
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range

      # Handle single prefix
      destination_address_prefix = (
        can(security_rule.value.destination_address_prefix) && security_rule.value.destination_address_prefix != null
        ? security_rule.value.destination_address_prefix
        : null
      )

      # Handle multiple prefixes
      destination_address_prefixes = (
        can(security_rule.value.destination_address_prefixes) && security_rule.value.destination_address_prefixes != null
        ? toset(security_rule.value.destination_address_prefixes)
        : null
      )
    }
  }
}
