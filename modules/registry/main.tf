locals {
  requires_storage_account_id = length(var.runner_identity_access) > 0 || local.container_create
  requires_container_id = length(var.artifacts) > 0

  storage_account_create = var.storage_account_create && var.storage_account_id == null && var.container_id == null
  storage_account_load = local.requires_storage_account_id && !local.storage_account_create
  storage_account_id = (var.storage_account_id != null ? var.storage_account_id :
      local.storage_account_create ? azurerm_storage_account.artifacts[0].id :
        local.storage_account_load ? data.azurerm_storage_account.artifacts[0].id :
        null)
  storage_account_name = (var.storage_account_name != null ? var.storage_account_name :
      local.storage_account_create ? azurerm_storage_account.artifacts[0].name :
        local.storage_account_load ? data.azurerm_storage_account.artifacts[0].name : null)

  container_create = var.container_create && var.container_id == null
  container_load = !var.container_create && var.container_id == null && local.requires_container_id
  container_id = (var.container_id != null ? var.container_id :
      local.container_create ? azurerm_storage_container.artifacts[0].id:
        local.container_load ? data.azurerm_storage_container.artifacts[0].id : null)
  container_name = (var.container_name != null ? var.container_name :
      local.container_create ? azurerm_storage_container.artifacts[0].name:
        local.container_load ? data.azurerm_storage_container.artifacts[0].name : null)

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location != null ? var.resource_group_location : data.azurerm_resource_group.resource_group[0].location
}

data "azurerm_resource_group" "resource_group" {
  count = var.resource_group_location == null ? 1 : 0

  name = var.resource_group_name
}

resource "azurerm_storage_account" "artifacts" {
  count = local.storage_account_create ? 1 : 0

  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
}

data "azurerm_storage_account" "artifacts" {
  count = local.storage_account_load ? 1 : 0

  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_storage_container" "artifacts" {
  count = local.container_create ? 1 : 0

  name                  = var.container_name
  storage_account_id    = local.storage_account_id
  container_access_type = "private"
}

data "azurerm_storage_container" "artifacts" {
  count = local.container_load ? 1 : 0

  name                  = var.container_name
  storage_account_id    = local.storage_account_id != null ? local.storage_account_id : null
  storage_account_name    = local.storage_account_id != null ? null : var.storage_account_name
}

resource "azurerm_role_assignment" "runner_storage_reader" {
  for_each = var.runner_identity_access

  scope                = local.storage_account_id
  # TODO more refined role for read/write
  # https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
  role_definition_name = each.value.read_only ? "Storage Blob Data Reader" : "Storage Blob Data Contributor"
  principal_id         = each.value.principal_id
  description          = each.value.read_only ? "Read access for ${each.key} VMSS instances and dev VMs" : "Read/Write access for ${each.key} VMSS instances and dev VMs"
}

resource "azurerm_storage_blob" "artifacts" {
  for_each = var.artifacts

  name                   = each.key
  storage_container_id   = local.container_id
  type                   = "Block"
  source                 = each.value.source
  content_type           = each.value.content_type
}
