variable "name" {
  type        = string
  description = "Base name for the runner pool and associated resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to use"
}

variable "resource_group_location" {
  type        = string
  default     = null
  description = "The location of the resource group use. If not provided, the location is dynamically loaded thanks to a data block"
}

variable "subnet_id" {
  type        = string
  description = "Subnet where to deploy all the runners"
}

variable "vm_identity_id" {
  type        = string
  default     = null
  description = "Id of the existing identity to assign to the runner VMs and dev VMs"
}
variable "vm_identity_name" {
  type        = string
  description = "The name of the VM User Assigned Identity to create if `vm_identity_id` is not provided. When null, it defaults to the `name` variable followed by `-id`."
  default     = null
}
variable "vm_identity_create" {
  type        = bool
  description = "Should the vm identity be created if no `vm_identity_id` is provided"
  default     = true
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
  default     = 50
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
variable "vm_admin_ssh_public_key" {
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

variable "dev_vm_name_prefix" {
  type        = string
  default     = null
  description = "Prefix for the dev vm name"
}
variable "dev_vm_size" {
  type        = string
  default     = null
  description = "Size of the development VMs. Default is the value of `vm_size`"
}
variable "dev_vm_disk_size_gb" {
  type        = number
  default     = null
  description = "Size for the primary disk of the dev VMs, in Gb"
}
variable "dev_vms_count" {
  type        = number
  description = "The number of standalone development VMs to create for testing the image."
  default     = 0
}
variable "dev_vm_admin_username" {
  type        = string
  default     = null
  description = "Admin username of the dev vms. Default is `vm_admin_username`"
}
variable "dev_vm_admin_password" {
  type        = string
  default     = null
  description = "The password for the administrator user. Default is `vm_admin_username`"
}
variable "dev_vm_admin_ssh_public_key" {
  type        = string
  default     = null
  description = "Public ssh key for the admin user on the dev machines. Default is `vm_admin_ssh_public_key`"
}
variable "dev_vm_image_id" {
  type        = string
  default     = null
  description = "Image id for the dev machine. When null, value is `vm_image_id`"
}
variable "dev_vm_image_name" {
  type        = string
  default     = null
  description = "The name of the custom image to use for the VMs. The image is expected to be in the same resource group."
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

variable "devops_service_endpoint_id" {
  type        = string
  description = "Id of the Azure DevOps Service endpoint to use. When not provided, the id is taken from either the existing or a newly created `devops_service_endpoint_name` Service Endpoint, based on the `devops_service_endpoint_create` variable."
  default     = null
}

variable "devops_runners_pool_name" {
  type        = string
  description = "The name of the Azure DevOps elastic agent pool. If null, it defaults to the `name` variable."
  default     = null
}

variable "devops_runners_count_min" {
  type        = number
  description = "The minimum number of idle agents Azure DevOps should keep warm."
  default     = 0
}

variable "devops_runners_count_max" {
  type        = number
  description = "The maximum number of agents allowed in the elastic pool."
  default     = 2
}

variable "devops_runner_ttl_minutes" {
  type        = number
  description = "The number of minutes to wait before deleting excess idle agents."
  default     = 15
}

variable "devops_runner_recycle_after_each_use" {
  type        = bool
  description = "Whether Azure DevOps should tear down and recreate the VM after every job execution."
  default     = false
}

variable "registry_storage_mounts" {
  # key = storage_account_name
  type        = map(object({
    mount_path      = optional(string, null)
    cache_path      = optional(string, null)
    read_only       = optional(bool, true)
    container_name  = string
  }))
  default     = {}
  description = "List of Storage Account container to mount in both the runner and dev VM instances. The name of the Storage account to use is the key of the entries in the map."
}
