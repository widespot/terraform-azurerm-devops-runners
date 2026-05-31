output "packer_pkrvars" {
  value = <<-EOT
  # packer.pkrvars.hcl
  subscription_id = "${data.azurerm_subscription.subscription.subscription_id}"
  resource_group_name = "${local.resource_group_name}"
  resource_grouo_location = "${local.resource_group_location}"
  vm_image_name = "${var.name}-vmimg"
  EOT
}

output "artifacts_storage_account_name" {
  value = var.registry_storage_account_create ? module.registry[0].storage_account_name : null
}

output "artifacts_mount_path" {
  value = var.registry_storage_account_create && var.registry_mount_enabled ? var.registry_mount_path : null
}

output "artifacts_download_example" {
  value = var.registry_storage_account_create ? "az login --identity && az storage blob download --account-name ${module.registry[0].storage_account_name} --container-name ${module.registry[0].storage_account_name} --name <blob_name> --file <destination_path> --auth-mode login" : null
}
