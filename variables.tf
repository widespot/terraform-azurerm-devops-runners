variable "name" {
  type        = string
  description = "Base name for the project."
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be created."
  default     = "westeurope"
}

variable "resource_group_create" {
  type        = bool
  default     = true
  description = "Whether to create a new resource group or use an existing one."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to create if `resource_group_create` is true, or use. If null, it defaults to the `name` variable followed by `-rg`."
  default     = null
}

variable "network_create" {
  type        = bool
  description = "Whether to create a new Virtual Network and Subnet for the runner VMSS."
  default     = true
}
variable "network_name" {
  type        = string
  description = "The name of the Virtual Network to create if `network_create` is true, or to use. If null, it defaults to the `name` variable followed by `-vnet`."
  default     = null
}
variable "network_cidr" {
  type        = string
  description = "The address space for the Virtual Network in CIDR notation, if it must be created."
  default     = "10.42.0.0/16"
}

variable "subnet_create" {
  type        = bool
  description = "Whether to create a new subnet within the Virtual Network."
  default     = true
}
variable "subnet_name" {
  type        = string
  description = "The name of the subnet to create if `subnet_create` is true, or to use."
  default     = "runners"
}
variable "subnet_cidr" {
  type        = string
  description = "The address space for the subnet in CIDR notation, if it must be created. When null, it defaults to the first /2 subnet of the network CIDR."
  default     = null
}

variable "nat_gateway_create" {
  type        = bool
  description = "Whether to create a NAT Gateway for the subnet. The NAT gateway is required if subnet only delivers private IP address. Or the runners have no access to internet (and therefore no access to Azure DevOps)."
  default     = true
}

variable "registries" {
  type = map(object({
    storage_account_name = optional(string, null)
    storage_account_create = optional(bool, true)
    container_name = optional(string, "registry")
  }))
  default = {}
  description = "List of registry storages to deploy. See [Registry module documentation](./modules/registry/README.md) for the description of attributes. "
}

variable "runners" {
  type = map(object({
    vm_name = optional(string, null)
    vm_size = optional(string, "Standard_D4s_v5")
    vm_disk_size_gb = optional(number, 50)
    vm_image_id = optional(string, null)
    vm_image_name = optional(string, null)
    vm_init_instances = optional(number, 0)
    vm_admin_username = optional(string, "azdo")
    vm_admin_password = optional(string, null)
    vm_admin_ssh_public_key = optional(string, null)

    dev_vm_name_prefix = optional(string, null)
    dev_vm_size = optional(string, null)
    dev_vm_disk_size_gb = optional(number, null)
    dev_vm_image_id = optional(string, null)
    dev_vm_image_name = optional(string, null)
    dev_vm_count = optional(number, 0)
    dev_vm_admin_username = optional(string, null)
    dev_vm_admin_password = optional(string, null)
    dev_vm_admin_ssh_public_key = optional(string, null)

    registry_storage_mounts = optional(map(object({
      mount_path = optional(string)
      cache_path = optional(string)
      read_only = optional(bool)
    })), {})

    devops_project_name = optional(string)
    devops_organization = optional(string)
    devops_service_connection_id = optional(string)
    devops_token_issuer = optional(string)
    devops_token_subject = optional(string)
  }))
  default = {}
  description = "List of Runners to deploy. See [Runner module documentation](./modules/runner/README.md) for the description of attributes. "
}

variable "devops_registrations" {
  description = "List of registrations in devops. The key of the map must match a key in of the `runners` map for the registration to work. See [Devops module documentation](./modules/devops) for the description of attributes."
  type        = map(object({

    project_id = optional(string)
    project_name = optional(string)

    service_connection_create = optional(bool, true)
    service_connection_name = optional(string, null)
    service_connection_id = optional(string, null)

    runner_pool_create = optional(bool, true)
    runner_pool_name = optional(string, null)

    runner_pool_size_min = optional(number, 0)
    runner_pool_size_max = optional(number, 2)

    runner_ttl_minutes = optional(number, 15)

    runner_recycle_after_each_use = optional(bool, false)
  }))
  default     = {}
}
