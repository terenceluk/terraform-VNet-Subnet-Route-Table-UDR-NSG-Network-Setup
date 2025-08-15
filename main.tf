# Conditional creation or import of a resource group
resource "azurerm_resource_group" "resource_group" {
  count    = var.resource_group_mode == "create" ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

# Fetch an existing resource group if `import` mode is specified
data "azurerm_resource_group" "existing_resource_group" {
  count = var.resource_group_mode == "import" ? 1 : 0
  name  = var.resource_group_name
}

# Dynamically determine the resource group ID
locals {
  resource_group_id = (
    var.resource_group_mode == "create"
    ? azurerm_resource_group.resource_group[0].id
    : data.azurerm_resource_group.existing_resource_group[0].id
  )
}

# Call VNet Module
module "vnets" {
  source              = "./networking-modules/vnet"
  for_each            = var.vnet_configs
  name                = each.value.name
  address_space       = each.value.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  rg_id               = local.resource_group_id
  tags                = var.tags
  depends_on          = [azurerm_resource_group.resource_group]
}

# Call Subnet Module
module "subnets" {
  source               = "./networking-modules/subnet"
  for_each             = var.assignments # Use the assignments map
  name                 = each.value.name
  address_prefixes     = each.value.address_prefixes
  virtual_network_name = module.vnets[each.value.vnet_name].name
  resource_group_name  = var.resource_group_name
}

# Call Route Table Module
module "route_tables" {
  source              = "./networking-modules/route-table"
  for_each            = var.route_table_configs
  name                = each.value.name
  routes              = each.value.routes
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  depends_on          = [azurerm_resource_group.resource_group]
}

# Call Route Table Assignments Module
module "route_table_assignments" {
  source = "./networking-modules/route-table-assignment"

  route_table_assignments = {
    for key, value in var.assignments :
    key => {
      subnet_id      = module.subnets[key].id # Use dynamically created subnet ID
      route_table_id = module.route_tables[value.route_table].id
    }
    if value.route_table != null # Skip subnets without route tables
  }
}

/*
# Call IP Group Module
module "ip_groups" {
  source              = "./networking-modules/ip-group"
  ip_groups           = var.ip_groups
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  depends_on          = [azurerm_resource_group.resource_group]
}
*/

# Call NSG Module
module "nsgs" {
  source              = "./networking-modules/nsg"
  for_each            = var.nsg_configs
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = each.value.security_rules
  tags                = var.tags
  depends_on          = [azurerm_resource_group.resource_group]
}

# Call NSG Assignments Module
module "nsg_assignments" {
  source = "./networking-modules/nsg-assignment"

  nsg_assignments = {
    for key, value in var.assignments :
    key => {
      subnet_id = module.subnets[key].id    # Use dynamically created subnet ID
      nsg_id    = module.nsgs[value.nsg].id # Use dynamically created NSG ID
    }
    if value.nsg != null # Skip subnets without NSGs
  }

}
