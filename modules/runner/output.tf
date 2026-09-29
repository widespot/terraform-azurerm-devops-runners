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

output "vmss_id" {
  description = "The ID of the Linux Virtual Machine Scale Set for runners if created; null otherwise."
  value       = local.vm_image_id == null ? null : azurerm_linux_virtual_machine_scale_set.runner[0].id
}

output "vmss_name" {
  description = "The name of the Linux Virtual Machine Scale Set for runners if created; null otherwise."
  value       = local.vm_image_id == null ? null : azurerm_linux_virtual_machine_scale_set.runner[0].name
}

output "vmss_unique_id" {
  description = "The unique ID of the Linux Virtual Machine Scale Set for runners if created; null otherwise."
  value       = local.vm_image_id == null ? null : azurerm_linux_virtual_machine_scale_set.runner[0].unique_id
}

output "vm_identity_id" {
  description = "The ID of the User Assigned Identity used by the runner instances."
  value       = local.vm_identity_id
}

output "vm_identity_name" {
  description = "The name of the User Assigned Identity used by the runner instances if created or looked up; null if an explicit vm_identity_id was provided."
  value       = var.vm_identity_id == null ? (var.vm_identity_create ? azurerm_user_assigned_identity.runner[0].name : data.azurerm_user_assigned_identity.runner[0].name) : null
}

output "vm_identity_principal_id" {
  description = "The Principal ID (object ID) of the User Assigned Identity if created or looked up; null if an explicit vm_identity_id was provided."
  value       = var.vm_identity_id == null ? (var.vm_identity_create ? azurerm_user_assigned_identity.runner[0].principal_id : data.azurerm_user_assigned_identity.runner[0].principal_id) : null
}

output "vm_identity_client_id" {
  description = "The Client ID of the User Assigned Identity if created or looked up; null if an explicit vm_identity_id was provided."
  value       = var.vm_identity_id == null ? (var.vm_identity_create ? azurerm_user_assigned_identity.runner[0].client_id : data.azurerm_user_assigned_identity.runner[0].client_id) : null
}

output "devops_app_registration_client_id" {
  description = "The Application (client) ID of the Azure AD Application registration created for Azure DevOps OIDC integration, if enabled; null otherwise."
  value       = local.devops_manual_registration ? azuread_application_registration.runner[0].client_id : null
}

output "devops_app_registration_object_id" {
  description = "The Object ID of the Azure AD Application registration created for Azure DevOps OIDC integration, if enabled; null otherwise."
  value       = local.devops_manual_registration ? azuread_application_registration.runner[0].object_id : null
}

output "devops_service_principal_id" {
  description = "The Object ID of the Azure AD Service Principal created for Azure DevOps OIDC integration, if enabled; null otherwise."
  value       = local.devops_manual_registration ? azuread_service_principal.runner[0].object_id : null
}

output "azdo_vmss_discovery_role_definition_id" {
  description = "The Resource ID of the custom AzDO VMSS Discovery role definition, if created; null otherwise."
  value       = local.devops_manual_registration ? azurerm_role_definition.azdo_vmss_discovery[0].role_definition_resource_id : null
}

output "azdo_vmss_operator_role_definition_id" {
  description = "The Resource ID of the custom AzDO VMSS Operator role definition, if created; null otherwise."
  value       = local.devops_manual_registration ? azurerm_role_definition.azdo_vmss_operator[0].role_definition_resource_id : null
}

output "dev_vm_ids" {
  description = "List of resource IDs of the standalone development VMs."
  value       = [for vm in azurerm_virtual_machine.dev_vm : vm.id]
}

output "dev_vm_names" {
  description = "List of names of the standalone development VMs."
  value       = [for vm in azurerm_virtual_machine.dev_vm : vm.name]
}

output "dev_vm_public_ips" {
  description = "List of public IP addresses assigned to the standalone development VMs."
  value       = [for ip in azurerm_public_ip.dev_ip : ip.ip_address]
}

output "dev_vm_private_ips" {
  description = "List of private IP addresses assigned to the standalone development VMs."
  value       = [for nic in azurerm_network_interface.dev_network_interface : nic.private_ip_address]
}

output "dev_vm_network_security_group_id" {
  description = "The ID of the Network Security Group associated with development VMs, if created; null otherwise."
  value       = length(azurerm_network_security_group.dev_nsg) > 0 ? azurerm_network_security_group.dev_nsg[0].id : null
}
