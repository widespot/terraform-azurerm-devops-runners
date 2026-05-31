locals {
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location != null ? var.resource_group_location : data.azurerm_resource_group.resource_group[0].location

  vm_identity_name = coalesce(var.vm_identity_name, "${var.name}-id")
  vm_identity_id   = var.vm_identity_id != null ? var.vm_identity_id : azurerm_user_assigned_identity.runner[0].id

  vm_image_id      = var.vm_image_id != null ? var.vm_image_id : (var.vm_image_name == null ? null : "/subscriptions/${data.azurerm_subscription.subscription.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/images/${var.vm_image_name}")
  vm_name          = coalesce(var.vm_name, "${var.name}-vm")
  vm_nic_name      = "${local.vm_name}-nic"

  scale_set_name = "${var.name}-vmss"
}

data "azurerm_resource_group" "resource_group" {
  count = var.resource_group_location == null ? 1 : 0

  name = local.resource_group_name
}

resource "azurerm_user_assigned_identity" "runner" {
  count = var.vm_identity_id == null ? 1 : 0

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
  custom_data    = local.artifacts_mount_enabled ? base64encode(local.artifacts_mount_cloud_init) : null
  dynamic "admin_ssh_key" {
    for_each = var.vm_admin_ssh_public_key == null ? [] : [0]
    content {
      username   = var.vm_admin_username
      public_key = var.vm_admin_ssh_public_key
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [local.vm_identity_id]
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
      subnet_id = var.subnet_id
    }
  }

  lifecycle {
    ignore_changes = [
      instances,
      tags,
    ]
  }
}
