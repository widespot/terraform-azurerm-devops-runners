locals {
  resource_group_name_default = coalesce(var.resource_group_name, "${var.name}-rg")
  resource_group_name         = var.resource_group_create ? azurerm_resource_group.resource_group[0].name : data.azurerm_resource_group.resource_group[0].name
  resource_group_location     = var.resource_group_create ? azurerm_resource_group.resource_group[0].location : data.azurerm_resource_group.resource_group[0].location

  vm_identity_name = coalesce(var.vm_identity_name, "${var.name}-id")
  vm_identity_principal_id = azurerm_user_assigned_identity.runner.principal_id
}

data "azurerm_subscription" "subscription" {
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
  name                = local.vm_identity_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}

module "registry" {
  source = "../registry"

  storage_account_create  = var.registry_storage_account_create
  storage_account_name    = var.registry_storage_account_name
  storage_account_id      = var.registry_storage_account_id
  container_create        = var.registry_container_create
  container_name          = var.registry_container_name
  container_id            = var.registry_container_id

  resource_group_name     = coalesce(var.registry_resource_group_name, local.resource_group_name)
  resource_group_location = coalesce(var.registry_resource_group_location, local.resource_group_location)

  runner_identity_access = {
    runner = {
      principal_id = local.vm_identity_principal_id,
      read_only = var.registry_mount_read_only,
    }
  }

  depends_on = [
    azurerm_user_assigned_identity.runner
  ]

  artifacts = var.artifacts
}

module "runner" {
  source = "../runner"

  name                    = var.name
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  subnet_id = module.network.subnet_id

  vm_identity_name    = local.vm_identity_name
  # Because azurerm_user_assigned_identity.runner is listed as dependency, we expect the identity to exist
  vm_identity_create  = false

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

  devops_organization = var.devops_organization
  devops_project_name = var.devops_project_name
  devops_service_connection_id = var.devops_service_connection_id
  devops_token_issuer = var.devops_token_issuer
  devops_token_subject = var.devops_token_subject
  devops_agent_version = var.devops_agent_version
  devops_agent_enable_script_version = var.devops_agent_enable_script_version

  registry_storage_mounts = var.registry_mount_enabled ? {(module.registry[0].storage_account_name) = {
    mount_path          = var.registry_mount_path
    cache_path          = var.registry_mount_cache_path
    read_only           = var.registry_mount_read_only
    container_name      = module.registry[0].container_name
  }} : {}

  depends_on = [
    azurerm_user_assigned_identity.runner
  ]
}
