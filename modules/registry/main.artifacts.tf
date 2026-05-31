locals {
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location != null ? var.resource_group_location : data.azurerm_resource_group.resource_group[0].location

  storage_account_name = var.storage_account_name
}

data "azurerm_resource_group" "resource_group" {
  count = var.resource_group_location == null ? 1 : 0

  name = var.resource_group_name
}

resource "azurerm_storage_account" "artifacts" {
  count = var.storage_account_create ? 1 : 0

  name                     = local.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
}

resource "azurerm_storage_container" "artifacts" {
  count = var.storage_account_create ? 1 : 0

  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.artifacts[0].id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "runner_storage_reader" {
  for_each = var.storage_account_create ? var.runner_principal_ids : {}

  scope                = azurerm_storage_account.artifacts[0].id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.value
}

resource "azurerm_storage_blob" "artifacts" {
  for_each = var.storage_account_create ? var.artifacts : {}

  name                   = each.key
  storage_account_name   = azurerm_storage_account.artifacts[0].name
  storage_container_name = azurerm_storage_container.artifacts[0].name
  type                   = "Block"
  source                 = each.value.source
  content_type           = each.value.content_type
}
