output "resource_group_name" {
  description = "The name of the resource group."
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group."
  value       = local.resource_group_location
}

output "network_id" {
  description = "The ID of the Virtual Network."
  value       = var.network_create ? azurerm_virtual_network.network[0].id : data.azurerm_virtual_network.network[0].id
}

output "network_name" {
  description = "The name of the Virtual Network."
  value       = local.network_name
}

output "network_cidr" {
  description = "The address space of the Virtual Network."
  value       = local.network_cidr
}

output "subnet_id" {
  description = "The ID of the subnet."
  value       = local.subnet_id
}

output "subnet_name" {
  description = "The name of the subnet."
  value       = local.subnet_name
}

output "subnet_cidr" {
  description = "The address prefix of the subnet."
  value       = local.subnet_cidr_default
}

output "network_security_group_id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.subnet_nsg.id
}

output "network_security_group_name" {
  description = "The name of the Network Security Group."
  value       = azurerm_network_security_group.subnet_nsg.name
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway if created; null otherwise."
  value       = var.nat_gateway_create ? azurerm_nat_gateway.nat[0].id : null
}

output "nat_gateway_name" {
  description = "The name of the NAT Gateway if created; null otherwise."
  value       = var.nat_gateway_create ? azurerm_nat_gateway.nat[0].name : null
}

output "public_ip_id" {
  description = "The ID of the Public IP associated with the NAT Gateway if created; null otherwise."
  value       = var.nat_gateway_create ? azurerm_public_ip.nat[0].id : null
}

output "public_ip_address" {
  description = "The IP address of the Public IP associated with the NAT Gateway if created; null otherwise."
  value       = var.nat_gateway_create ? azurerm_public_ip.nat[0].ip_address : null
}
