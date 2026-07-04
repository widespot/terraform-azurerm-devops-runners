locals {
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location != null ? var.resource_group_location : data.azurerm_resource_group.resource_group[0].location

  vm_identity_default_name = coalesce(var.vm_identity_name, "${var.name}-id")
  vm_identity_id           = var.vm_identity_id != null ? var.vm_identity_id : var.vm_identity_create ? azurerm_user_assigned_identity.runner[0].id: data.azurerm_user_assigned_identity.runner[0].id

  vm_image_id      = var.vm_image_id != null ? var.vm_image_id : (var.vm_image_name == null ? null : "/subscriptions/${data.azurerm_subscription.subscription.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/images/${var.vm_image_name}")
  vm_name          = coalesce(var.vm_name, "${var.name}-vm")
  vm_nic_name      = "${local.vm_name}-nic"

  scale_set_name = "${var.name}-vmss"
}

data "azurerm_resource_group" "resource_group" {
  count = var.resource_group_location == null ? 1 : 0

  name = local.resource_group_name
}

resource "azurerm_user_assigned_identity" "runner" {
  count = var.vm_identity_id == null && var.vm_identity_create ? 1 : 0

  name                = local.vm_identity_default_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}

data "azurerm_user_assigned_identity" "runner" {
  count = var.vm_identity_id == null && !var.vm_identity_create ? 1 : 0

  name                = local.vm_identity_default_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_linux_virtual_machine_scale_set" "runner" {
  count = local.vm_image_id == null ? 0 : 1

  name                = local.scale_set_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  sku       = var.vm_size
  instances = var.vm_init_instances

  source_image_id = local.vm_image_id

  disable_password_authentication = var.vm_admin_password != null ? false : true
  overprovision                   = false
  single_placement_group          = false
  upgrade_mode                    = "Manual"

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password
  custom_data    = length(var.registry_storage_mounts) > 0 ? base64encode(local.registry_mount_cloud_init) : null
  dynamic "admin_ssh_key" {
    for_each = var.vm_admin_ssh_public_key == null ? [] : [0]
    content {
      username   = var.vm_admin_username
      public_key = var.vm_admin_ssh_public_key
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [local.vm_identity_id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.vm_disk_size_gb
  }

  network_interface {
    name    = local.vm_nic_name
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  lifecycle {
    ignore_changes = [
      instances,
      tags,
    ]
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "extension" {
  count = local.vm_image_id == null ? 0 : 1

  name                         = "Microsoft.Azure.DevOps.Pipelines.Agent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.runner[0].id
  publisher                    = "Microsoft.VisualStudio.Services"
  type                         = "TeamServicesAgentLinux"
  type_handler_version         = "1.26"
  # curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest \
  #  | jq -r '.tag_name | ltrimstr("v")'
  settings = jsonencode({
    agentDownloadUrl        = "https://download.agent.dev.azure.com/agent/${var.devops_agent_version}/vsts-agent-linux-x64-${var.devops_agent_version}.tar.gz"
    agentFolder             = "/agent"
    enableScriptDownloadUrl = "https://vstsagenttools.blob.core.windows.net/tools/ElasticPools/Linux/${var.devops_agent_enable_script_version}/enableagent.sh"
    isPipelinesAgent        = true
  })
  auto_upgrade_minor_version = false
  automatic_upgrade_enabled = false
  provision_after_extensions = []
}

data "azurerm_subscription" "subscription" {
}
