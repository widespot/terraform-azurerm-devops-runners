locals {
  vm_identity_name = coalesce(var.vm_identity_name, "${var.name}-id")
  vm_image_id      = var.vm_image_id != null ? var.vm_image_id : (var.vm_image_name == null ? null : "/subscriptions/${data.azurerm_subscription.subscription.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/images/${var.vm_image_name}")
  vm_name          = coalesce(var.vm_name, "${var.name}-vm")
  vm_nic_name      = "${local.vm_name}-nic"

  scale_set_name = "${var.name}-vmss"

  artifacts_blobfuse_mount_enabled = var.artifacts_storage_create && var.artifacts_blobfuse_mount_enabled
  artifacts_blobfuse_mount_options = var.artifacts_blobfuse_mount_read_only ? "ro,allow_other" : "allow_other"
  artifacts_blobfuse_cloud_init = local.artifacts_blobfuse_mount_enabled ? (
    <<-EOT
    #cloud-config
    package_update: true
    bootcmd:
      - mkdir -p /etc/blobfuse2
    packages:
      - fuse3
      - libfuse3-dev
    write_files:
      - path: /etc/blobfuse2/artifacts.yaml
        permissions: "0600"
        owner: root:root
        content: |
          version: 2
          logging:
            type: syslog
            level: log_warning
          components:
            - libfuse
            - attr_cache
            - azstorage
          libfuse:
            attribute-expiration-sec: 120
            entry-expiration-sec: 120
            negative-entry-expiration-sec: 120
          attr_cache:
            timeout-sec: 120
          azstorage:
            type: block
            account-name: ${azurerm_storage_account.artifacts[0].name}
            container: ${azurerm_storage_container.artifacts[0].name}
            endpoint: https://${azurerm_storage_account.artifacts[0].name}.blob.core.windows.net
            mode: msi
    runcmd:
      - bash -lc '. /etc/os-release; curl -fsSL "https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb" -o /tmp/packages-microsoft-prod.deb'
      - dpkg -i /tmp/packages-microsoft-prod.deb
      - apt-get update
      - apt-get install -y blobfuse2
      - mkdir -p ${var.artifacts_blobfuse_tmp_path}
      - mkdir -p ${var.artifacts_blobfuse_mount_path}
      - grep -q "^blobfuse2 ${var.artifacts_blobfuse_mount_path} " /etc/fstab || echo "blobfuse2 ${var.artifacts_blobfuse_mount_path} fuse3 defaults,_netdev,--config-file=/etc/blobfuse2/artifacts.yaml,--tmp-path=${var.artifacts_blobfuse_tmp_path},${local.artifacts_blobfuse_mount_options} 0 0" >> /etc/fstab
      - mount -a
    EOT
  ) : null
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
  custom_data    = local.artifacts_blobfuse_mount_enabled ? base64encode(local.artifacts_blobfuse_cloud_init) : null
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
