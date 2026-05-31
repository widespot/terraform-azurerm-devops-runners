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
  count = var.resource_group_create ? 1 : 0

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
  source = "modules/registries"

  for_each = var.registries

  storage_account_name    = each.key
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  runner_principal_ids           = [for runner in local.registry_runners[each.key] : "${var.name}-${runner}-id"]
}

module "runners" {
  source = "modules/runner"

  for_each = var.runners

  name                    = each.key
  resource_group_name     = local.resource_group_name
  resource_group_location = local.resource_group_location

  subnet_id = module.network.subnet_id

  devops_project_name = each.value.devops_project_name

  artifacts_storage_mount = {for k, v in each.value.registries: module.registries[k].storage_account_name => {
    mount_path = v.mount_path
    blobfuse_cache_path = v.blobfuse_cache_path
    read_only = v.read_only
  }}
}
