output "resource_group_id" {
  description = "The ID of the resource group."
  value       = var.resource_group_create ? azurerm_resource_group.resource_group[0].id : data.azurerm_resource_group.resource_group[0].id
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group."
  value       = local.resource_group_location
}

output "tenant_id" {
  description = "The Azure tenant ID of the subscription."
  value       = data.azurerm_subscription.subscription.tenant_id
}

output "subscription_id" {
  description = "The Azure subscription ID."
  value       = data.azurerm_subscription.subscription.subscription_id
}

output "subscription_name" {
  description = "The display name of the Azure subscription."
  value       = data.azurerm_subscription.subscription.display_name
}

output "network_id" {
  description = "The ID of the Virtual Network."
  value       = module.network.network_id
}

output "network_name" {
  description = "The name of the Virtual Network."
  value       = module.network.network_name
}

output "network_cidr" {
  description = "The address space of the Virtual Network."
  value       = module.network.network_cidr
}

output "subnet_id" {
  description = "The ID of the subnet."
  value       = module.network.subnet_id
}

output "subnet_name" {
  description = "The name of the subnet."
  value       = module.network.subnet_name
}

output "subnet_cidr" {
  description = "The address prefix of the subnet."
  value       = module.network.subnet_cidr
}

output "network_security_group_id" {
  description = "The ID of the Network Security Group."
  value       = module.network.network_security_group_id
}

output "network_security_group_name" {
  description = "The name of the Network Security Group."
  value       = module.network.network_security_group_name
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway if created; null otherwise."
  value       = module.network.nat_gateway_id
}

output "nat_gateway_name" {
  description = "The name of the NAT Gateway if created; null otherwise."
  value       = module.network.nat_gateway_name
}

output "public_ip_id" {
  description = "The ID of the Public IP associated with the NAT Gateway if created; null otherwise."
  value       = module.network.public_ip_id
}

output "public_ip_address" {
  description = "The IP address of the Public IP associated with the NAT Gateway if created; null otherwise."
  value       = module.network.public_ip_address
}

output "vm_identity_id" {
  description = "The ID of the User Assigned Identity used by the runner instances."
  value       = local.vm_identity_id
}

output "vm_identity_name" {
  description = "The name of the User Assigned Identity used by the runner instances."
  value       = local.vm_identity_name
}

output "vm_identity_principal_id" {
  description = "The Principal ID (object ID) of the User Assigned Identity."
  value       = local.vm_identity_principal_id
}

output "vm_identity_client_id" {
  description = "The Client ID of the User Assigned Identity."
  value       = local.vm_identity_create ? azurerm_user_assigned_identity.runner[0].client_id : data.azurerm_user_assigned_identity.runner[0].client_id
}

output "storage_account_id" {
  description = "The ID of the storage account used for artifacts registry."
  value       = module.registry.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account used for artifacts registry."
  value       = module.registry.storage_account_name
}

output "container_id" {
  description = "The ID of the blob container used for artifacts registry."
  value       = module.registry.container_id
}

output "container_name" {
  description = "The name of the blob container used for artifacts registry."
  value       = module.registry.container_name
}

output "artifacts_mount_path" {
  description = "The mount path of the artifacts blob container on runner instances, if enabled; null otherwise."
  value       = var.registry_storage_account_create && var.registry_mount_enabled ? var.registry_mount_path : null
}

output "vmss_id" {
  description = "The ID of the Linux Virtual Machine Scale Set for runners if created; null otherwise."
  value       = module.runner.vmss_id
}

output "vmss_name" {
  description = "The name of the Linux Virtual Machine Scale Set for runners if created; null otherwise."
  value       = module.runner.vmss_name
}

output "vmss_unique_id" {
  description = "The unique ID of the Linux Virtual Machine Scale Set for runners if created; null otherwise."
  value       = module.runner.vmss_unique_id
}

output "devops_app_registration_client_id" {
  description = "The Application (client) ID of the Azure AD Application registration created for Azure DevOps OIDC integration, if enabled; null otherwise."
  value       = module.runner.devops_app_registration_client_id
}

output "devops_app_registration_object_id" {
  description = "The Object ID of the Azure AD Application registration created for Azure DevOps OIDC integration, if enabled; null otherwise."
  value       = module.runner.devops_app_registration_object_id
}

output "devops_service_principal_id" {
  description = "The Object ID of the Azure AD Service Principal created for Azure DevOps OIDC integration, if enabled; null otherwise."
  value       = module.runner.devops_service_principal_id
}

output "azdo_vmss_discovery_role_definition_id" {
  description = "The Resource ID of the custom AzDO VMSS Discovery role definition, if created; null otherwise."
  value       = module.runner.azdo_vmss_discovery_role_definition_id
}

output "azdo_vmss_operator_role_definition_id" {
  description = "The Resource ID of the custom AzDO VMSS Operator role definition, if created; null otherwise."
  value       = module.runner.azdo_vmss_operator_role_definition_id
}

output "dev_vm_ids" {
  description = "List of resource IDs of the standalone development VMs."
  value       = module.runner.dev_vm_ids
}

output "dev_vm_names" {
  description = "List of names of the standalone development VMs."
  value       = module.runner.dev_vm_names
}

output "dev_vm_public_ips" {
  description = "List of public IP addresses assigned to the standalone development VMs."
  value       = module.runner.dev_vm_public_ips
}

output "dev_vm_private_ips" {
  description = "List of private IP addresses assigned to the standalone development VMs."
  value       = module.runner.dev_vm_private_ips
}

output "dev_vm_network_security_group_id" {
  description = "The ID of the Network Security Group associated with development VMs, if created; null otherwise."
  value       = module.runner.dev_vm_network_security_group_id
}

output "packer_pkrvars" {
  description = "Packer pkrvars configuration snippet for building custom runner images."
  value       = <<-EOT
  # packer.pkrvars.hcl
  subscription_id = "${data.azurerm_subscription.subscription.subscription_id}"
  resource_group_name = "${local.resource_group_name}"
  resource_group_location = "${local.resource_group_location}"
  vm_image_name = "${var.name}-vmimg"
  EOT
}
