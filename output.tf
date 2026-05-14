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
  value = var.artifacts_storage_create ? azurerm_storage_account.artifacts[0].name : null
}

output "artifacts_container_name" {
  value = var.artifacts_storage_create ? azurerm_storage_container.artifacts[0].name : null
}

output "artifacts" {
  value = var.artifacts_storage_create ? { for k, v in azurerm_storage_blob.artifacts : k => v.url } : {}
}

output "artifacts_download_example" {
  value = var.artifacts_storage_create ? "az login --identity && az storage blob download --account-name ${azurerm_storage_account.artifacts[0].name} --container-name ${azurerm_storage_container.artifacts[0].name} --name <blob_name> --file <destination_path> --auth-mode login" : null
}
