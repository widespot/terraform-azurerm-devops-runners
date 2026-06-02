# Custom DevOps Runner on Azure, with Terraform

> Build and deploy a DevOps runners on Azure using Terraform in 10 minutes

## Features
* [x] One line automated deployment
* [x] Multiple runners, 
* [x] 100% configurable and modular
* [x] Deploy additional "dev" VM instances to test the runner image
* [x] mount shared blob storage on the runners as additional volumes
* [x] Upload artifact on the azure Storage account
* [x] Include automated or guided Azure DevOps configuration
* [x] Support for the creation of custom runner VM image (see [Option 2 of Usage section](#option-2-custom-runner-image-with-packer)

## Usage

### Prerequisites
* Have an Azure Devops organization and project
* Azure CLI installed and logged in
* Terraform installed and configured

### Option 1: Existing Runner image

```hcl
provider "azurerm" {
   features {}
   resource_provider_registrations = "none"
   # Visual Studio Professional Subscription = OK
   subscription_id = "00000000-0000-0000-0000-000000000000"
}
provider "azuredevops" {
    org_service_url = "https://dev.azure.com/widespot"
}

module "runner" {
   source = "git::https://github.com/widespot/terraform-azurerm-devops-runner.git//modules/simple?ref=v0.1.0"
   
   name = "test-runner"
   devops_project_name = "my-project"
   vm_ssh_public_key = file("~/.ssh/id_rsa.pub")
   
   vm_image_name = "..."
   # OR
   vm_image_id = "..."
}
```

### Option 2: Custom runner image (with packer)
This module is also designed to ease the creation of custom runner images. 
Deployment can split into three steps
1. **[Terraform]** using the module with `vm_image_name` and `vm_image_id` set to null so that only the Resource Group and supporting resources are created.
2. **[Packer, or alternative]** Build the image in the newly created Resource Group
3. **[Terraform]** pass the reference to the new `vm_image_name` or `vm_image_id` to `terraform apply` to finalize the deployment.

An example of this procedure is available in the [example](example) folder.

## Documentation
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.49.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.49.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_registries"></a> [registries](#module\_registries) | ./modules/registry | n/a |
| <a name="module_runners"></a> [runners](#module\_runners) | ./modules/runner | n/a |

### Resources

| Name | Type |
| ---- | ---- |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity.runner](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/data-sources/resource_group) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created. | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the project. | `string` | n/a | yes |
| <a name="input_nat_gateway_create"></a> [nat\_gateway\_create](#input\_nat\_gateway\_create) | Whether to create a NAT Gateway for the subnet. The NAT gateway is required if subnet only delivers private IP address. Or the runners have no access to internet (and therefore no access to Azure DevOps). | `bool` | `true` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | The address space for the Virtual Network in CIDR notation, if it must be created. | `string` | `"10.42.0.0/16"` | no |
| <a name="input_network_create"></a> [network\_create](#input\_network\_create) | Whether to create a new Virtual Network and Subnet for the runner VMSS. | `bool` | `true` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the Virtual Network to create if `network_create` is true, or to use. If null, it defaults to the `name` variable followed by `-vnet`. | `string` | `null` | no |
| <a name="input_registries"></a> [registries](#input\_registries) | List of registry storages to deploy. See [Registry module documentation](./modules/registry/README.md) for the description of attributes. | <pre>map(object({<br/>    storage_account_name = optional(string, null)<br/>    storage_account_create = optional(bool, true)<br/>    container_name = optional(string, "registry")<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_create"></a> [resource\_group\_create](#input\_resource\_group\_create) | Whether to create a new resource group or use an existing one. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to create if `resource_group_create` is true, or use. If null, it defaults to the `name` variable followed by `-rg`. | `string` | `null` | no |
| <a name="input_runners"></a> [runners](#input\_runners) | List of Runners to deploy. See [Runner module documentation](./modules/runner/README.md) for the description of attributes. | <pre>map(object({<br/>    vm_name = optional(string, null)<br/>    vm_size = optional(string, "Standard_D4s_v5")<br/>    vm_disk_size_gb = optional(number, 50)<br/>    vm_image_id = optional(string, null)<br/>    vm_image_name = optional(string, null)<br/>    vm_init_instances = optional(number, 0)<br/>    vm_admin_username = optional(string, "azdo")<br/>    vm_admin_password = optional(string, null)<br/>    vm_admin_ssh_public_key = optional(string, null)<br/><br/>    dev_vm_name_prefix = optional(string, null)<br/>    dev_vm_size = optional(string, null)<br/>    dev_vm_disk_size_gb = optional(number, null)<br/>    dev_vm_image_id = optional(string, null)<br/>    dev_vm_image_name = optional(string, null)<br/>    dev_vm_count = optional(number, 0)<br/>    dev_vm_admin_username = optional(string, null)<br/>    dev_vm_admin_password = optional(string, null)<br/>    dev_vm_admin_ssh_public_key = optional(string, null)<br/><br/>    registry_storage_mounts = optional(map(object({<br/>      mount_path = optional(string)<br/>      cache_path = optional(string)<br/>      read_only = optional(bool)<br/>    })), {})<br/>    devops_project_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | The address space for the subnet in CIDR notation, if it must be created. When null, it defaults to the first /2 subnet of the network CIDR. | `string` | `null` | no |
| <a name="input_subnet_create"></a> [subnet\_create](#input\_subnet\_create) | Whether to create a new subnet within the Virtual Network. | `bool` | `true` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet to create if `subnet_create` is true, or to use. | `string` | `"runners"` | no |

### Outputs

No outputs.
<!-- END_TF_DOCS -->

### Generate this documentation
```shell
terraform-docs markdown table --output-file README.md --indent 3 .
```

## TODO
* [ ] Support for Windows images
* [ ] Support for image building from dev VM
