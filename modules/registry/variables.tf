variable "storage_account_name" {
  type        = string
  description = "The name of the storage account for artifacts. If null, it defaults to the `name` variable (sanitized)."
}

variable "storage_account_create" {
  type        = bool
  description = "Whether to create the artifact storage account and container."
  default     = true
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

variable "runner_identity_access" {
  type        = map(object({
    principal_id = string
    read_only    = optional(bool, true)
  }))
  default     = {}
  description = "Map of runner key to User Managed Identity of the runners VM allowed to read the artifacts"
}

variable "container_create" {
  type = bool
  default = true
}

variable "container_name" {
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
