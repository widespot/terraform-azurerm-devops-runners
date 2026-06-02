output "vmss_id" {
  value = local.vm_image_id == null ? null : azurerm_linux_virtual_machine_scale_set.runner[0].id
}

output "tenant_id" {
  value = data.azurerm_subscription.subscription.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.subscription.subscription_id
}

output "subscription_name" {
  value = data.azurerm_subscription.subscription.display_name
}
