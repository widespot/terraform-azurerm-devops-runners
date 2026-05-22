locals {
  devops_service_endpoint_name_default = coalesce(var.devops_service_endpoint_name, "${var.name}-endpoint")
  devops_service_endpoint_id           = coalesce(var.devops_service_endpoint_id, var.devops_service_endpoint_create ? azuredevops_serviceendpoint_azurerm.service_endpoint[0].id : data.azuredevops_serviceendpoint_azurerm.service_endpoint[0].id)
}

data "azuredevops_project" "project" {
  name = var.devops_project_name
}

data "azurerm_subscription" "subscription" {
}

resource "azuredevops_serviceendpoint_azurerm" "service_endpoint" {
  count = var.devops_service_endpoint_create && var.devops_service_endpoint_id == null ? 1 : 0

  azurerm_spn_tenantid      = data.azurerm_subscription.subscription.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.subscription.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.subscription.display_name

  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = local.devops_service_endpoint_name_default

  #service_endpoint_authentication_scheme = "ManagedServiceIdentity"
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
}

data "azuredevops_serviceendpoint_azurerm" "service_endpoint" {
  count = var.devops_service_endpoint_create || var.devops_service_endpoint_id != null ? 0 : 1

  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = local.devops_service_endpoint_name_default
}

resource "azuredevops_elastic_pool" "runners_pool" {
  count = local.vm_image_id == null ? 0 : 1

  name                   = coalesce(var.runners_pool_name, var.name)
  azure_resource_id      = azurerm_linux_virtual_machine_scale_set.runner[0].id
  service_endpoint_id    = local.devops_service_endpoint_id
  service_endpoint_scope = data.azuredevops_project.project.id

  desired_idle           = var.runners_count_min
  max_capacity           = var.runners_count_max
  time_to_live_minutes   = var.runner_ttl_minutes
  recycle_after_each_use = var.runner_recycle_after_each_use

  auto_provision = true
  auto_update    = true
  project_id     = data.azuredevops_project.project.id

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
      azurerm_linux_virtual_machine_scale_set.runner[0]
    ]

    create_before_destroy = false
  }

  depends_on = [
    azurerm_linux_virtual_machine_scale_set.runner[0]
  ]
}

#resource "azuredevops_agent_queue" "runner" {
#  count = local.vm_image_id == null ? 0 : 1

#  project_id    = data.azuredevops_project.project.id
#  agent_pool_id = azuredevops_elastic_pool.runners_pool[0].id
#}
