locals {
  registry_storage_mounts = {for k,v in var.registry_storage_mounts: k => {
    mount_path = coalesce(v.mount_path, "/mnt/registries/${k}")
    cache_path = coalesce(v.cache_path, "/var/cache/blobfuse2/${k}")
    blobfuse_option = v.read_only ? "ro,allow_other" : "allow_other"
    container_name = v.container_name
  }}

  registry_mount_cloud_init = templatefile("${path.module}/templates/cloud-config.yml", {
    registry_storage_mounts = local.registry_storage_mounts
  })
}