locals {
  resource_group_name_default = coalesce(var.resource_group_name, "${var.name}-rg")
  resource_group_name         = var.resource_group_create ? azurerm_resource_group.resource_group[0].name : data.azurerm_resource_group.resource_group[0].name
  resource_group_location     = var.resource_group_create ? azurerm_resource_group.resource_group[0].location : data.azurerm_resource_group.resource_group[0].location

  registry_runners = {for registry in keys(var.registries): registry => [for runner in keys(var.runners): runner if contains(keys(var.runners[runner].registry_storage_mounts), registry)]}
}

resource "azurerm_resource_group" "resource_group" {
  count = var.resource_group_create ? 1 : 0

  location = var.location
  name     = local.resource_group_name_default
}

data "azurerm_resource_group" "resource_group" {
  count = var.resource_group_create ? 0 : 1

  name = local.resource_group_name_default
}

module "network" {
  source = "./modules/network"

  name                    = var.name
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  network_create  = var.network_create
  network_name    = var.network_name
  network_cidr    = var.network_cidr

  subnet_create = var.subnet_create
  subnet_name   = var.subnet_name
  subnet_cidr   = var.subnet_cidr

  nat_gateway_create = var.nat_gateway_create
}

resource "azurerm_user_assigned_identity" "runner" {
  for_each = var.runners

  name                = "${var.name}-${each.key}-id"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}

module "registries" {
  source = "./modules/registry"

  for_each = var.registries

  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  storage_account_name  = coalesce(each.value.storage_account_name, each.key)
  container_name        = each.value.container_name

  runner_principal_ids = {for runner in local.registry_runners[each.key] : runner => azurerm_user_assigned_identity.runner[runner].principal_id }
}

module "runners" {
  source = "./modules/runner"

  for_each = var.runners

  name                    = each.key
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  subnet_id = module.network.subnet_id

  vm_identity_name = "${var.name}-${each.key}-id"
  vm_identity_create = false

  vm_name = each.value.vm_name
  vm_size = each.value.vm_size
  vm_init_instances = each.value.vm_init_instances
  vm_image_id = each.value.vm_image_id
  vm_image_name = each.value.vm_image_name
  vm_disk_size_gb = each.value.vm_disk_size_gb
  vm_admin_username = each.value.vm_admin_username
  vm_admin_password = each.value.vm_admin_password
  vm_admin_ssh_public_key = each.value.vm_admin_ssh_public_key

  dev_vm_name_prefix = each.value.dev_vm_name_prefix
  dev_vm_size = each.value.dev_vm_size
  dev_vm_disk_size_gb = each.value.dev_vm_disk_size_gb
  dev_vms_count = each.value.dev_vm_count
  dev_vm_image_id = each.value.dev_vm_image_id
  dev_vm_image_name = each.value.dev_vm_image_name
  dev_vm_admin_username = each.value.dev_vm_admin_username
  dev_vm_admin_password = each.value.dev_vm_admin_password
  dev_vm_admin_ssh_public_key = each.value.dev_vm_admin_ssh_public_key

  devops_organization = each.value.devops_organization
  devops_project_name = each.value.devops_project_name
  devops_service_connection_id = each.value.devops_service_connection_id
  devops_token_issuer = each.value.devops_token_issuer
  devops_token_subject = each.value.devops_token_subject

  registry_storage_mounts = {for registry, v in each.value.registry_storage_mounts: module.registries[registry].storage_account_name => {
    mount_path = v.mount_path
    cache_path = v.cache_path
    read_only = v.read_only
    container_name = module.registries[registry].container_name
  }}

  depends_on = [
    azurerm_user_assigned_identity.runner
  ]
}

module "devops" {
  source = "./modules/devops"

  for_each = var.devops_registrations

  name   = each.key

  project_id = each.value.project_id
  project_name = each.value.project_name

  azure_vmss_id = module.runners[each.key].vmss_id

  service_connection_create = each.value.service_connection_create
  service_connection_name = each.value.service_connection_name
  service_connection_id = each.value.service_connection_id
  service_connection_tenant_id = module.runners[each.key].tenant_id
  service_connection_subscription_id = module.runners[each.key].subscription_id
  service_connection_subscription_name = module.runners[each.key].subscription_name
  service_connection_resource_group = local.resource_group_name

  runner_pool_create = each.value.runner_pool_create
  runner_pool_name = each.value.runner_pool_name

  runner_pool_size_min = each.value.runner_pool_size_min
  runner_pool_size_max = each.value.runner_pool_size_max

  runner_ttl_minutes = each.value.runner_ttl_minutes

  runner_recycle_after_each_use = each.value.runner_recycle_after_each_use
}
