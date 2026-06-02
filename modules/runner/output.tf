output "vmss_id" {
  value = local.vm_image_id == null ? null : azurerm_linux_virtual_machine_scale_set.runner[0].id
}
