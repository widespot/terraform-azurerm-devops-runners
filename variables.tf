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

  }))
  default = {}
}

variable "runners" {
  type = map(object({

    vm_name = optional(string, null)
    vm_size = optional(string, null)
    vm_disk_size_gb = optional(number, null)
    vm_image_id = optional(string, null)
    vm_image_name = optional(string, null)
    vm_init_instances = optional(number, null)
    vm_admin_username = optional(string, null)
    vm_admin_password = optional(string, null)
    vm_admin_ssh_public_key = optional(string, null)

    dev_vm_name_prefix = optional(string, null)
    dev_vm_size = optional(string, null)
    dev_vm_disk_size_gb = optional(number, null)
    dev_vm_image_id = optional(string, null)
    dev_vm_image_name = optional(string, null)
    dev_vm_count = optional(number, null)
    dev_vm_admin_username = optional(string, null)
    dev_vm_admin_password = optional(string, null)
    dev_vm_admin_ssh_public_key = optional(string, null)

    registries = map(object({
      mount_path = optional(string, null) # /mnt/artifacts/each.key
      blobfuse_cache_path = optional(string, null) # /var/cache/blobfuse2/
      read_only = optional(bool, true)
    }))
    devops_project_name = string
  }))
}
