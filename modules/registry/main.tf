locals {
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location != null ? var.resource_group_location : data.azurerm_resource_group.resource_group[0].location

  storage_account_name_default =  var.storage_account_name
  storage_account_name = var.storage_account_create ? azurerm_storage_account.artifacts[0].name : data.azurerm_storage_account.registry[0].name
  storage_container_name = var.storage_account_create ?  azurerm_storage_container.artifacts[0].name : var.container_name
}

data "azurerm_resource_group" "resource_group" {
  count = var.resource_group_location == null ? 1 : 0

  name = var.resource_group_name
}

resource "azurerm_storage_account" "artifacts" {
  count = var.storage_account_create ? 1 : 0

  name                     = local.storage_account_name_default
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
}

data "azurerm_storage_account" "registry" {
  count = var.storage_account_create ? 0 : 1

  name                = local.storage_account_name_default
  resource_group_name = local.resource_group_name
}

resource "azurerm_storage_container" "artifacts" {
  count = var.container_create ? 1 : 0

  name                  = var.container_name
  storage_account_id    = var.storage_account_create ? azurerm_storage_account.artifacts[0].id : data.azurerm_storage_account.registry[0].id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "runner_storage_reader" {
  for_each = var.runner_identity_access

  scope                = var.storage_account_create ? azurerm_storage_account.artifacts[0].id : data.azurerm_storage_account.registry[0].id
  # TODO more refined role for read/write
  # https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
  role_definition_name = each.value.read_only ? "Storage Blob Data Reader" : "Storage Blob Data Contributor"
  principal_id         = each.value.principal_id
  description          = each.value.read_only ? "Read access for ${each.key} VMSS instances and dev VMs" : "Read/Write access for ${each.key} VMSS instances and dev VMs"
}

resource "azurerm_storage_blob" "artifacts" {
  for_each = var.artifacts

  name                   = each.key
  storage_account_name   = local.storage_account_name
  storage_container_name = local.storage_container_name
  type                   = "Block"
  source                 = each.value.source
  content_type           = each.value.content_type
}
