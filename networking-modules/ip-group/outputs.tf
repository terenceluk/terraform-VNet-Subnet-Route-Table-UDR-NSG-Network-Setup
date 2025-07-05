output "ip_group_ids" {
  description = "The IDs of the created IP Groups."
  value       = [for ip_group in azurerm_ip_group.ip_group : ip_group.id]
}