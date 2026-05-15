variable "name" {
  type        = string
  description = "Base name for the runner pool and associated resources."
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

variable "vm_identity_name" {
  type        = string
  description = "The name of the User Assigned Identity for the VMs. When null, it defaults to the `name` variable followed by `-id`."
  default     = null
}
variable "vm_name" {
  type        = string
  description = "The base name for the Virtual Machine instances. When null, it defaults to the `name` variable followed by `-vm`."
  default     = null
}
variable "vm_size" {
  type        = string
  description = "The SKU (size) of the Virtual Machine Scale Set instances."
  default     = "Standard_D4s_v5"
}
variable "vm_disk_size_gb" {
  type        = number
  description = "Size for the primary disk of the VMs, in Gb"
  default     = 30
}
variable "vm_init_instances" {
  type        = number
  description = "The initial number of instances in the VMSS. Usually 0 as Azure DevOps manages the capacity."
  default     = 0
}
variable "vm_admin_username" {
  type        = string
  description = "The administrator username for the VM instances."
  default     = "azdo"
}
variable "vm_admin_password" {
  type        = string
  default     = null
  description = "The password for the administrator user. Either `vm_admin_password` or `vm_ssh_public_key` must be provided."
}
variable "vm_ssh_public_key" {
  type        = string
  default     = null
  description = "The SSH public key for the administrator user. Example: `file(\"~/.ssh/id_rsa.pub\")`. Either `vm_admin_password` or `vm_ssh_public_key` must be provided."
}
variable "vm_image_name" {
  type        = string
  description = "The name of the custom image to use for the VMs. The image is expected to be in the same resource group."
  default     = null
}
variable "vm_image_id" {
  type        = string
  description = "The full resource ID of the custom image to use for the VMs. When null, and `vm_image_name` is not null, value is /subscriptions/$${subscription_id}/resourceGroups/$${resource_group_name}/providers/Microsoft.Compute/images/$${vm_image_name}"
  default     = null
}

variable "dev_vms_count" {
  type        = number
  description = "The number of standalone development VMs to create for testing the image."
  default     = 0
}
variable "dev_vm_size" {
  type        = string
  default     = null
  description = "Size of the development VMs. Default is the value of `vm_size`"
}
variable "dev_vm_admin_password" {
  type        = string
  default     = null
  description = "The password for the administrator user."
}
variable "dev_vm_image_id" {
  type        = string
  default     = null
  description = "Image id for the dev machine. When null, value is `vm_image_id`"
}


variable "devops_project_name" {
  type        = string
  description = "The name of the Azure DevOps project where the runner pool will be created."
}

variable "devops_service_endpoint_create" {
  type        = bool
  description = "Whether to create a new AzureRM service connection in Azure DevOps."
  default     = true
}

variable "devops_service_endpoint_name" {
  type        = string
  default     = null
  description = "The name of the AzureRM service connection to use. If null, it defaults to the `name` variable followed by `-endpoint`."
}

variable "runners_pool_name" {
  type        = string
  description = "The name of the Azure DevOps elastic agent pool. If null, it defaults to the `name` variable."
  default     = null
}

variable "runners_count_min" {
  type        = number
  description = "The minimum number of idle agents Azure DevOps should keep warm."
  default     = 0
}

variable "runners_count_max" {
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

variable "artifacts_storage_create" {
  type        = bool
  description = "Whether to create the artifact storage account and container."
  default     = true
}

variable "artifacts_storage_account_name" {
  type        = string
  description = "The name of the storage account for artifacts. If null, it defaults to the `name` variable (sanitized)."
  default     = null
}

variable "artifacts_container_name" {
  type        = string
  description = "The name of the storage container for artifacts."
  default     = "artifacts"
}

variable "artifacts" {
  type = map(object({
    source       = string
    content_type = optional(string, "application/octet-stream")
  }))
  description = "A map of artifacts to upload to the storage container. The key is the blob name, and the value is an object with `source` (path to local file) and optional `content_type`."
  default     = {}
}
