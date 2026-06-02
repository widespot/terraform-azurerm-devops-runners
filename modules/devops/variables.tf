variable "name" {
  type        = string
  description = "Base name of the project."
}

variable "project_id" {
  type        = string
  description = "The id of the Azure DevOps project where the resources are created. Required if `project_name` is not defined"
  default     = null
}

variable "project_name" {
  type        = string
  description = "The name of the Azure DevOps project where the resources are created. Required if `project_id` is not defined"
  default     = null
}

variable "service_connection_create" {
  type        = bool
  description = "Whether to create a new AzureRM service connection in Azure DevOps."
  default     = true
}
variable "service_connection_name" {
  type        = string
  default     = null
  description = "The name of the AzureRM service connection to use or to create. If null, it defaults to the `name` variable followed by `-endpoint`."
}
variable "service_connection_id" {
  type        = string
  description = "Id of the Azure DevOps Service endpoint to use. When not provided, the id is taken from either the existing or a newly created `devops_service_endpoint_name` Service Endpoint, based on the `devops_service_endpoint_create` variable."
  default     = null
}
variable "service_connection_subscription_id" {
  type        = string
  default     = null
  description = "Id of the Azure Subscription in the scope of the service connection. When not provided and Service Connection to be created, the id of the current subscription is used"
}
variable "service_connection_subscription_name" {
  type        = string
  default     = null
  description = "Name of the Azure Subscription in the scope of the service connection. When not provided and Service Connection to be created, the name of the `service_connection_subscription_id` or the current subscription is used."
}
variable "service_connection_tenant_id" {
  type        = string
  default     = null
  description = "Tenant id in the scope of the service connection. When not provided and Service Connection to be created, the ID of the tenant of the `service_connection_subscription_id` or the current subscription is used"
}
variable "service_connection_resource_group" {
  type        = string
  default     = null
  description = "Azure Resource group in the scope of the service connection. When not provided and Service Connection to be created, the scope is the whole subscription."
}

variable "runner_pool_create" {
  type    = bool
  default = true
}

variable "runner_pool_name" {
  type        = string
  description = "The name of the Azure DevOps elastic agent pool. If null, it defaults to the `name` variable."
  default     = null
}

variable "runner_pool_size_min" {
  type        = number
  description = "The minimum number of idle agents Azure DevOps should keep warm."
  default     = 0
}

variable "runner_pool_size_max" {
  type        = number
  description = "The maximum number of agents allowed in the elastic pool."
  default     = 2
}

variable "runner_ttl_minutes" {
  type        = number
  description = "The number of minutes to wait before deleting excess idle agents."
  default     = 15
}

variable "runner_recycle_after_each_use" {
  type        = bool
  description = "Whether Azure DevOps should tear down and recreate the VM after every job execution."
  default     = false
}

variable "azure_vmss_id" {
  type        = string
  default     = null
  description = "Required when `runner_pool_create` is true"
}
