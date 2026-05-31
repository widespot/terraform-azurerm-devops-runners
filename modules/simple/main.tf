locals {
  resource_group_name_default = coalesce(var.resource_group_name, "${var.name}-rg")
  resource_group_name         = var.resource_group_create ? azurerm_resource_group.resource_group[0].name : data.azurerm_resource_group.resource_group[0].name
  resource_group_location     = var.resource_group_create ? azurerm_resource_group.resource_group[0].location : data.azurerm_resource_group.resource_group[0].location
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
  source = "../network"

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
  name                = coalesce(var.vm_identity_name, "${var.name}-id")
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}

module "registry" {
  source = "../registry"

  for_each = var.artifacts_storage_create ? {registry = {}} : {}

  storage_account_name    = var.registry_storage_account_name
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  container_name = var.registry_container_name

  runner_principal_ids           = [azurerm_user_assigned_identity.runner.id]
}

module "runner" {
  source = "../runner"

  name                    = var.name
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  subnet_id = module.network.subnet_id

  vm_identity_id = azurerm_user_assigned_identity.runner.id

  vm_name = var.vm_name
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
  vm_admin_ssh_public_key = var.vm_admin_ssh_public_key
  vm_disk_size_gb = var.vm_disk_size_gb
  vm_image_id = var.vm_image_id
  vm_image_name = var.vm_image_name
  vm_size = var.vm_size
  vm_init_instances = var.vm_init_instances

  dev_vms_count = var.dev_vms_count
  dev_vm_name_prefix = var.dev_vm_name_prefix
  dev_vm_admin_username = var.dev_vm_admin_username
  dev_vm_admin_password = var.dev_vm_admin_password
  dev_vm_admin_ssh_public_key = var.dev_vm_admin_ssh_public_key
  dev_vm_disk_size_gb = var.dev_vm_disk_size_gb
  dev_vm_image_id = var.dev_vm_image_id
  dev_vm_image_name = var.dev_vm_image_name
  dev_vm_size = var.dev_vm_size

  devops_project_name = var.devops_project_name
  devops_runner_recycle_after_each_use = var.devops_runner_recycle_after_each_use
  devops_runner_ttl_minutes = var.devops_runner_ttl_minutes
  devops_runners_count_max = var.devops_runners_count_max
  devops_runners_count_min = var.devops_runners_count_min
  devops_runners_pool_name =  var.devops_runners_pool_name
  devops_service_endpoint_create = var.devops_service_endpoint_create
  devops_service_endpoint_id = var.devops_service_endpoint_id
  devops_service_endpoint_name = var.devops_service_endpoint_name

  artifacts_storage_mount = var.artifacts_storage_create && var.registry_mount_enabled ? {var.registry_storage_account_name = {
    mount_path = var.registry_mount_path
    blobfuse_cache_path = var.registry_mount_cache_path
    read_only = var.registry_mount_read_only
  }} : {}
}
