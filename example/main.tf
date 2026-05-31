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

  vm_image_name = "tempo-runner-vmimg3"
  vm_ssh_public_key = file("~/.ssh/id_rsa.pub")
  vm_admin_password = "Password1!"

  dev_vms_count = 1
  vm_size = "Standard_D8s_v5"
  dev_vm_image_id = "/subscriptions/083e56a7-a090-4ad2-b62f-13b7e69fc648/resourceGroups/tempo-runner-rg/providers/Microsoft.Compute/images/tempo-runner-vmimg8"

  artifacts = {
    repo = {
      source = "test-artifact.txt"
    }
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
