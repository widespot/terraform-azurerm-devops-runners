variable "name" {
  type        = string
  description = "Base name for the runner pool and associated resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to use."
}

variable "resource_group_location" {
  type        = string
  default     = null
  description = "The location of the resource group use. If not provided, the location is dynamically loaded thanks to a data block"
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
  default     = null
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
