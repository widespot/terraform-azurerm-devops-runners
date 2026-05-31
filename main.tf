locals {
  resource_group_name_default = coalesce(var.resource_group_name, "${var.name}-rg")
  resource_group_name         = var.resource_group_create ? azurerm_resource_group.resource_group[0].name : data.azurerm_resource_group.resource_group[0].name
  resource_group_location     = var.resource_group_create ? azurerm_resource_group.resource_group[0].location : data.azurerm_resource_group.resource_group[0].location

  registry_runners = {for registry in keys(var.registries): registry => [for runner in keys(var.runners): runner if contains(keys(var.runners[runner].registries), registry)]}
}

resource "azurerm_resource_group" "resource_group" {
  count = var.resource_group_create ? 1 : 0

  location = var.location
  name     = local.resource_group_name_default
}

data "azurerm_resource_group" "resource_group" {
  count = var.resource_group_create ? 0 : 1

  name = var.resource_group_name
}

module "network" {
  source = "modules/network"

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
  source = "modules/registry"

  for_each = var.registries

  storage_account_name    = each.key
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  runner_principal_ids = [for runner in local.registry_runners[each.key] : azurerm_user_assigned_identity.runner[runner].id]
}

module "runners" {
  source = "modules/runner"

  for_each = var.runners

  name                    = each.key
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  subnet_id = module.network.subnet_id

  vm_identity_id = azurerm_user_assigned_identity.runner[each.key].id

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

  devops_project_name = each.value.devops_project_name
  devops_runner_recycle_after_each_use = null
  devops_runner_ttl_minutes = null
  devops_runners_count_max = null
  devops_runners_count_min = null
  devops_runners_pool_name =  null
  devops_service_endpoint_create = null
  devops_service_endpoint_id = null
  devops_service_endpoint_name = null

  artifacts_storage_mount = {for registry, v in each.value.registries: module.registries[registry].storage_account_name => {
    mount_path = v.mount_path
    blobfuse_cache_path = v.blobfuse_cache_path
    read_only = v.read_only
  }}
}
