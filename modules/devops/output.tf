output "project_id" {
  description = "Azure DevOps project ID used by this module."
  value = local.project_id
}

output "project_name" {
  description = "Azure DevOps project name provided to this module."
  value = var.project_name
}

output "service_connection_id" {
  description = "ID of the AzureRM service connection used by the runner pool."
  value = local.service_endpoint_id
}

output "service_connection_name" {
  description = "Name of the AzureRM service connection used or created by this module."
  value = local.service_endpoint_name_default
}

output "service_connection_created" {
  description = "Whether this module created the AzureRM service connection during apply."
  value = !var.service_connection_create || var.service_connection_id != null ? false : true
}

output "service_connection_subscription_id" {
  description = "Azure subscription ID associated with the service connection."
  value = local.subscription_id
}

output "service_connection_subscription_name" {
  description = "Azure subscription name associated with the service connection."
  value = local.subscription_name
}

output "service_connection_tenant_id" {
  description = "Azure tenant ID associated with the service connection."
  value = local.tenant_id
}

output "service_connection_resource_group" {
  description = "Resource group scope configured on the service connection, if any."
  value = var.service_connection_resource_group
}

output "runner_pool_id" {
  description = "ID of the Azure DevOps elastic runner pool when created; null otherwise."
  value = var.runner_pool_create ? azuredevops_elastic_pool.runners_pool[0].id : null
}

output "runner_pool_name" {
  description = "Name of the Azure DevOps elastic runner pool."
  value = coalesce(var.runner_pool_name, var.name)
}

output "runner_pool_created" {
  description = "Whether this module is configured to create the runner pool."
  value = var.runner_pool_create
}

output "runner_pool_size_min" {
  description = "Configured minimum number of warm idle runners in the elastic pool."
  value = var.runner_pool_size_min
}

output "runner_pool_size_max" {
  description = "Configured maximum number of runners allowed in the elastic pool."
  value = var.runner_pool_size_max
}

output "runner_ttl_minutes" {
  description = "Configured idle runner time-to-live in minutes before scale down."
  value = var.runner_ttl_minutes
}

output "runner_recycle_after_each_use" {
  description = "Whether runners are recycled after each job execution."
  value = var.runner_recycle_after_each_use
}

output "azure_vmss_id" {
  description = "Azure Virtual Machine Scale Set resource ID attached to the runner pool."
  value = var.azure_vmss_id
}
