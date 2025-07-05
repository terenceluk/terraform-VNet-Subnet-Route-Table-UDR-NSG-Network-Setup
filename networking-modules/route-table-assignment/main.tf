resource "azurerm_subnet_route_table_association" "route_table_assignment" {
  for_each        = var.route_table_assignments
  subnet_id       = each.value.subnet_id
  route_table_id  = each.value.route_table_id
}