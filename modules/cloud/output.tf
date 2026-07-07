output "packer_pkrvars" {
  value = <<-EOT
  # packer.pkrvars.hcl
  subscription_id = "${data.azurerm_subscription.subscription.subscription_id}"
  resource_group_name = "${local.resource_group_name}"
  resource_grouo_location = "${local.resource_group_location}"
  vm_image_name = "${var.name}-vmimg"
  EOT
}

output "artifacts_mount_path" {
  value = var.registry_storage_account_create && var.registry_mount_enabled ? var.registry_mount_path : null
}

output "devops_app_registration_client_id" {
  value = module.runner.devops_app_registration_client_id
}

