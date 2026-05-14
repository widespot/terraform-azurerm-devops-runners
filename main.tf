locals {
  vm_identity_name = coalesce(var.vm_identity_name, "${var.name}-id")
  vm_image_id      = var.vm_image_id != null ? var.vm_image_id : (var.vm_image_name == null ? null : "/subscriptions/${data.azurerm_subscription.subscription.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/images/${var.vm_image_name}")
  vm_name          = coalesce(var.vm_name, "${var.name}-vm")
  vm_nic_name      = "${local.vm_name}-nic"

  scale_set_name = "${var.name}-vmss"
}

resource "azurerm_user_assigned_identity" "runner" {
  name                = local.vm_identity_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}

resource "azurerm_linux_virtual_machine_scale_set" "runner" {
  count = local.vm_image_id == null ? 0 : 1

  name                = local.scale_set_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  sku       = var.vm_size
  instances = var.vm_init_instances

  source_image_id = local.vm_image_id

  disable_password_authentication = var.vm_admin_password != null ? false : true
  overprovision                   = false
  single_placement_group          = false
  upgrade_mode                    = "Manual"

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password
  dynamic "admin_ssh_key" {
    for_each = var.vm_ssh_public_key == null ? [] : [0]
    content {
      username   = var.vm_admin_username
      public_key = var.vm_ssh_public_key
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.runner.id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.vm_disk_size_gb
  }

  network_interface {
    name    = local.vm_nic_name
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = local.subnet_id
    }
  }

  lifecycle {
    ignore_changes = [
      instances,
      tags,
    ]
  }
}