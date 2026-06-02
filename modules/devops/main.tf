locals {
  project_id = coalesce(var.project_id, data.azuredevops_project.project[0].project_id)

  service_endpoint_name_default = coalesce(var.service_connection_name, "${var.name}-connection")
  service_endpoint_id = var.service_connection_id != null ? var.service_connection_id : var.service_connection_create ? azuredevops_serviceendpoint_azurerm.service_endpoint[0].id : data.azuredevops_serviceendpoint_azurerm.service_endpoint[0].id

  subscription_id = var.service_connection_subscription_id != null ? var.service_connection_subscription_id : data.azurerm_subscription.subscription[0].subscription_id
  subscription_name = var.service_connection_subscription_name != null ? var.service_connection_subscription_name : data.azurerm_subscription.subscription[0].display_name
  tenant_id = var.service_connection_tenant_id != null ? var.service_connection_tenant_id : data.azurerm_subscription.subscription[0].tenant_id
}

data "azuredevops_project" "project" {
  count = var.project_id == null ? 1 : 0

  name = var.project_name
}

data "azurerm_subscription" "subscription" {
  count = (var.service_connection_id == null && (var.service_connection_tenant_id == null || var.service_connection_subscription_name == null || var.service_connection_subscription_id == null)) ? 1 : 0

  subscription_id = var.service_connection_subscription_id
}

resource "azuredevops_serviceendpoint_azurerm" "service_endpoint" {
  count = !var.service_connection_create || var.service_connection_id != null ? 0 : 1

  azurerm_spn_tenantid      = local.tenant_id
  azurerm_subscription_id   = local.subscription_id
  azurerm_subscription_name = local.subscription_name
  resource_group            = var.service_connection_resource_group

  project_id            = local.project_id
  service_endpoint_name = local.service_endpoint_name_default

  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
}

data "azuredevops_serviceendpoint_azurerm" "service_endpoint" {
  count = var.service_connection_create || var.service_connection_id != null ? 0 : 1

  project_id            = local.project_id
  service_endpoint_name = local.service_endpoint_name_default
}

resource "terraform_data" "azure_vmss_id" {
  input = var.azure_vmss_id
}

resource "azuredevops_elastic_pool" "runners_pool" {
  count = var.runner_pool_create ? 1 : 0

  name                   = coalesce(var.runner_pool_name, var.name)
  azure_resource_id      = var.azure_vmss_id
  service_endpoint_id    = local.service_endpoint_id
  service_endpoint_scope = local.project_id

  desired_idle           = var.runner_pool_size_min
  max_capacity           = var.runner_pool_size_max
  time_to_live_minutes   = var.runner_ttl_minutes
  recycle_after_each_use = var.runner_recycle_after_each_use

  auto_provision = true
  auto_update    = true
  project_id     = local.project_id

  # Updating the VMSS inplace must trigger a replacement of the the elastic pool
  # A simple change in a VMSS parameter indeed can lead to clearing the settings of the Extension.
  # Since The Elastic pool do not continuously enforce the setting of the VMSS extension, the
  # Newly instantiatied VM will miss the setting, and won't connect to AzDo
  #
  #  az vmss extension set \
  #--resource-group test-runner-rg \
  #--vmss-name test-runner-vmss \
  #--name Microsoft.Azure.DevOps.Pipelines.Agent \
  #--publisher Microsoft.VisualStudio.Services \
  #--settings @settings.json

  lifecycle {
    replace_triggered_by = [
      terraform_data.azure_vmss_id
    ]

    create_before_destroy = false
  }
}

#resource "azuredevops_agent_queue" "runner" {
#  count = local.vm_image_id == null ? 0 : 1

#  project_id    = data.azuredevops_project.project.id
#  agent_pool_id = azuredevops_elastic_pool.runners_pool[0].id
#}
