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
  source = "../"

  name = "tempo-runner"
  devops_project_name = var.devops_project_name

  vm_image_name = var.vm_image_name
  vm_ssh_public_key = file("~/.ssh/id_rsa.pub")
  vm_admin_password = "Password1!"

  #dev_vms_count = 1
  #dev_vm_image_id = "/subscriptions/f9da3531-9249-48b4-b5e9-707a8f643b40/resourceGroups/test-runner-rg/providers/Microsoft.Compute/images/test-runner-vmimg"

  artifacts = {
    #repo = {
    #  source = "/Users/raphaeljoie/Downloads/Archive.zip"
    #}
  }
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
