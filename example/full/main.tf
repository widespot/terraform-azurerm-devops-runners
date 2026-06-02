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


module "full" {
  source = "../../"

  name = "ws-runner"

  registries = {
    legacy-reg = {
      storage_account_name = "legacyreg"
      storage_account_create = true
      container_name = "all"
    }
    newwave = {
      storage_account_create = true
    }
  }
  runners = {
    tempo-internal = {
      devops_project_name = var.devops_project_name
      vm_admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
      vm_admin_password = "Password1!"
      registry_mount_points = {
        legacy-reg = {}
        newwave = {}
      }
      vm_image_name = "ws-runner-vmimg"
    }
    tempo-shared = {
      devops_project_name = var.devops_project_name
      registry_mount_points = {
        newwave = {}
      }
    }
    belgium = {
      devops_project_name = var.devops_project_name
    }
  }
  devops_registrations = {
    tempo-internal = {
      project_name = var.devops_project_name
    }
  }
}

variable "devops_project_name" {
  type = string
}