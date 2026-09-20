terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 1.0.0"
    }
  }
}

module "runner" {
  source = "../../modules/simple"

  name = "tempo-runner"
  devops_project_name = var.devops_project_name

  vm_image_name = "tempo-runner-vmimg8"
  vm_admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  vm_admin_password = "Password1!"
  vm_disk_size_gb = 150

  registry_storage_account_create = false
  registry_storage_account_name = "runnerartifacts"
  registry_mount_read_only = false
  registry_container_name = "dist"
  registry_mount_enabled = true
  registry_mount_path = "/mnt/dist"

  devops_agent_version = "5.275.0"
  devops_agent_enable_script_version = "18"

  dev_vms_count = 1
  vm_size = "Standard_D8s_v5"

  #artifacts = {
  #  repo = {
  #    source = "test-artifact.txt"
  #  }
  #}
}

variable "devops_project_name" {
  type = string
  default = "project-name"
}

variable "vm_image_name" {
  type = string
  default = null
}

output "packer_pkrvars" {
  value = module.runner.packer_pkrvars
}

output "download" {
  value = module.runner.artifacts_download_example
}

output "image_name" {
  value = "tempo-runner-vmimg"
}
