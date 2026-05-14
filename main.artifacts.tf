locals {
  artifacts_storage_account_name = coalesce(var.artifacts_storage_account_name, replace(lower("${var.name}artifacts"), "/[^a-z0-9]/", ""))
}

resource "azurerm_storage_account" "artifacts" {
  count = var.artifacts_storage_create ? 1 : 0

  name                     = local.artifacts_storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
}

resource "azurerm_storage_container" "artifacts" {
  count = var.artifacts_storage_create ? 1 : 0

  name                  = var.artifacts_container_name
  storage_account_id    = azurerm_storage_account.artifacts[0].id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "runner_storage_reader" {
  count = var.artifacts_storage_create ? 1 : 0

  scope                = azurerm_storage_account.artifacts[0].id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.runner.principal_id
}

resource "azurerm_storage_blob" "artifacts" {
  for_each = var.artifacts_storage_create ? var.artifacts : {}

  name                   = each.key
  storage_account_name   = azurerm_storage_account.artifacts[0].name
  storage_container_name = azurerm_storage_container.artifacts[0].name
  type                   = "Block"
  source                 = each.value.source
  content_type           = each.value.content_type
}
