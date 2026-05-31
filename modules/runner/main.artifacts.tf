locals {
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