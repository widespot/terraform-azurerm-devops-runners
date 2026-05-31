locals {
  artifacts_storage_account_name = coalesce(var.artifacts_storage_account_name, replace(lower("${var.name}artifacts"), "/[^a-z0-9]/", ""))

  artifacts_mount_enabled = var.artifacts_storage_create && var.artifacts_mount_enabled
  artifacts_mount_blobfuse_options = var.artifacts_mount_read_only ? "ro,allow_other" : "allow_other"
  artifacts_mount_cloud_init = local.artifacts_mount_enabled ? (
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
      - mkdir -p ${var.artifacts_blobfuse_cache_path}
      - mkdir -p ${var.artifacts_mount_path}
      - grep -q "^blobfuse2 ${var.artifacts_mount_path} " /etc/fstab || echo "blobfuse2 ${var.artifacts_mount_path} fuse3 defaults,_netdev,--config-file=/etc/blobfuse2/artifacts.yaml,--tmp-path=${var.artifacts_blobfuse_cache_path},${local.artifacts_mount_blobfuse_options} 0 0" >> /etc/fstab
      - mount -a
    EOT
  ) : null
}

resource "azurerm_storage_account" "artifacts" {
  count = var.artifacts_storage_create ? 1 : 0

  name                     = local.artifacts_storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
}

resource "azurerm_storage_container" "artifacts" {
  count = var.artifacts_storage_create ? 1 : 0

  name                  = var.artifacts_container_name
  storage_account_id    = azurerm_storage_account.artifacts[0].id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "runner_storage_reader" {
  count = var.artifacts_storage_create ? 1 : 0

  scope                = azurerm_storage_account.artifacts[0].id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.runner.principal_id
}

resource "azurerm_storage_blob" "artifacts" {
  for_each = var.artifacts_storage_create ? var.artifacts : {}

  name                   = each.key
  storage_account_name   = azurerm_storage_account.artifacts[0].name
  storage_container_name = azurerm_storage_container.artifacts[0].name
  type                   = "Block"
  source                 = each.value.source
  content_type           = each.value.content_type
}
