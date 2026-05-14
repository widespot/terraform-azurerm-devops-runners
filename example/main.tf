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

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
  # Visual Studio Professional Subscription
  subscription_id = "f9da3531-9249-48b4-b5e9-707a8f643b40"
}

provider "azuredevops" {
  org_service_url = "https://dev.azure.com/widespot"
}

module "runner" {
  source = "../"

  name = "test-runner"
  devops_project_name = "oncall-shared"
  vm_ssh_public_key = file("~/.ssh/id_rsa.pub")
  dev_vms_count = 1

  # Uncomment once the image is created
  vm_image_name = var.vm_image_name

  artifacts = {
    rocky = {
      source = "/Users/raphaeljoie/Downloads/rocky-10.1-x86_64-minimal.iso"
    },
    repo = {
      source = "/Users/raphaeljoie/Downloads/Archive.zip"
    }
  }
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
