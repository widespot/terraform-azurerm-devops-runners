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
| <a name="module_network"></a> [network](#module\_network) | ../network | n/a |
| <a name="module_registry"></a> [registry](#module\_registry) | ../registry | n/a |
| <a name="module_runner"></a> [runner](#module\_runner) | ../runner | n/a |

### Resources

| Name | Type |
| ---- | ---- |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity.runner](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/data-sources/subscription) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_artifacts"></a> [artifacts](#input\_artifacts) | A map of artifacts to upload to the storage container. The key is the blob name, and the value is an object with `source` (path to local file) and optional `content_type`. | <pre>map(object({<br/>    source       = string<br/>    content_type = optional(string, "application/octet-stream")<br/>  }))</pre> | `{}` | no |
| <a name="input_dev_vm_admin_password"></a> [dev\_vm\_admin\_password](#input\_dev\_vm\_admin\_password) | The password for the administrator user of the dev VM instances. | `string` | `null` | no |
| <a name="input_dev_vm_admin_ssh_public_key"></a> [dev\_vm\_admin\_ssh\_public\_key](#input\_dev\_vm\_admin\_ssh\_public\_key) | The SSH public key for the administrator user. Example: `file("~/.ssh/id_rsa.pub")`. Default is `dev_vm_admin_ssh_public_key`. | `string` | `null` | no |
| <a name="input_dev_vm_admin_username"></a> [dev\_vm\_admin\_username](#input\_dev\_vm\_admin\_username) | The administrator username for the dev VM instances. | `string` | `null` | no |
| <a name="input_dev_vm_disk_size_gb"></a> [dev\_vm\_disk\_size\_gb](#input\_dev\_vm\_disk\_size\_gb) | Size for the primary disk of the dev VMs, in Gb | `number` | `null` | no |
| <a name="input_dev_vm_image_id"></a> [dev\_vm\_image\_id](#input\_dev\_vm\_image\_id) | Image id for the dev machine. When null, value is `vm_image_id` | `string` | `null` | no |
| <a name="input_dev_vm_image_name"></a> [dev\_vm\_image\_name](#input\_dev\_vm\_image\_name) | The name of the custom image to use for the dev VMs. The image is expected to be in the same resource group. | `string` | `null` | no |
| <a name="input_dev_vm_name_prefix"></a> [dev\_vm\_name\_prefix](#input\_dev\_vm\_name\_prefix) | prefix for the dev vms | `string` | `null` | no |
| <a name="input_dev_vm_size"></a> [dev\_vm\_size](#input\_dev\_vm\_size) | Size of the development VMs. Default is the value of `vm_size` | `string` | `null` | no |
| <a name="input_dev_vms_count"></a> [dev\_vms\_count](#input\_dev\_vms\_count) | The number of standalone development VMs to create for testing the image. | `number` | `0` | no |
| <a name="input_devops_project_name"></a> [devops\_project\_name](#input\_devops\_project\_name) | The name of the Azure DevOps project where the runner pool will be created. | `string` | n/a | yes |
| <a name="input_devops_runner_recycle_after_each_use"></a> [devops\_runner\_recycle\_after\_each\_use](#input\_devops\_runner\_recycle\_after\_each\_use) | Whether Azure DevOps should tear down and recreate the VM after every job execution. | `bool` | `false` | no |
| <a name="input_devops_runner_ttl_minutes"></a> [devops\_runner\_ttl\_minutes](#input\_devops\_runner\_ttl\_minutes) | The number of minutes to wait before deleting excess idle agents. | `number` | `15` | no |
| <a name="input_devops_runners_count_max"></a> [devops\_runners\_count\_max](#input\_devops\_runners\_count\_max) | The maximum number of agents allowed in the elastic pool. | `number` | `2` | no |
| <a name="input_devops_runners_count_min"></a> [devops\_runners\_count\_min](#input\_devops\_runners\_count\_min) | The minimum number of idle agents Azure DevOps should keep warm. | `number` | `0` | no |
| <a name="input_devops_runners_pool_name"></a> [devops\_runners\_pool\_name](#input\_devops\_runners\_pool\_name) | The name of the Azure DevOps elastic agent pool. If null, it defaults to the `name` variable. | `string` | `null` | no |
| <a name="input_devops_service_endpoint_create"></a> [devops\_service\_endpoint\_create](#input\_devops\_service\_endpoint\_create) | Whether to create a new AzureRM service connection in Azure DevOps. | `bool` | `true` | no |
| <a name="input_devops_service_endpoint_id"></a> [devops\_service\_endpoint\_id](#input\_devops\_service\_endpoint\_id) | Id of the Azure DevOps Service endpoint to use. When not provided, the id is taken from either the existing or a newly created `devops_service_endpoint_name` Service Endpoint, based on the `devops_service_endpoint_create` variable. | `string` | `null` | no |
| <a name="input_devops_service_endpoint_name"></a> [devops\_service\_endpoint\_name](#input\_devops\_service\_endpoint\_name) | The name of the AzureRM service connection to use. If null, it defaults to the `name` variable followed by `-endpoint`. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created. | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the runner pool and associated resources. | `string` | n/a | yes |
| <a name="input_nat_gateway_create"></a> [nat\_gateway\_create](#input\_nat\_gateway\_create) | Whether to create a NAT Gateway for the subnet. The NAT gateway is required if subnet only delivers private IP address. Or the runners have no access to internet (and therefore no access to Azure DevOps). | `bool` | `true` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | The address space for the Virtual Network in CIDR notation, if it must be created. | `string` | `"10.42.0.0/16"` | no |
| <a name="input_network_create"></a> [network\_create](#input\_network\_create) | Whether to create a new Virtual Network and Subnet for the runner VMSS. | `bool` | `true` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the Virtual Network to create if `network_create` is true, or to use. If null, it defaults to the `name` variable followed by `-vnet`. | `string` | `null` | no |
| <a name="input_registry_container_name"></a> [registry\_container\_name](#input\_registry\_container\_name) | The name of the storage container for artifacts. | `string` | `"artifacts"` | no |
| <a name="input_registry_mount_cache_path"></a> [registry\_mount\_cache\_path](#input\_registry\_mount\_cache\_path) | Local cache path used by Blobfuse2. | `string` | `"/var/cache/blobfuse2"` | no |
| <a name="input_registry_mount_enabled"></a> [registry\_mount\_enabled](#input\_registry\_mount\_enabled) | Whether to mount the artifacts blob container on all runner instances using Blobfuse2 with managed identity. | `bool` | `true` | no |
| <a name="input_registry_mount_path"></a> [registry\_mount\_path](#input\_registry\_mount\_path) | Path where the artifacts blob container is mounted on runner instances. | `string` | `"/mnt/registry"` | no |
| <a name="input_registry_mount_read_only"></a> [registry\_mount\_read\_only](#input\_registry\_mount\_read\_only) | Whether to mount the artifacts blob container in read-only mode on runner instances. | `bool` | `true` | no |
| <a name="input_registry_storage_account_create"></a> [registry\_storage\_account\_create](#input\_registry\_storage\_account\_create) | Whether to create the artifact storage account and container. | `bool` | `true` | no |
| <a name="input_registry_storage_account_name"></a> [registry\_storage\_account\_name](#input\_registry\_storage\_account\_name) | The name of the storage account for artifacts. If null, it defaults to the `name` variable (sanitized). | `string` | `null` | no |
| <a name="input_resource_group_create"></a> [resource\_group\_create](#input\_resource\_group\_create) | Whether to create a new resource group or use an existing one. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to create if `resource_group_create` is true, or use. If null, it defaults to the `name` variable followed by `-rg`. | `string` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | The address space for the subnet in CIDR notation, if it must be created. When null, it defaults to the first /2 subnet of the network CIDR. | `string` | `null` | no |
| <a name="input_subnet_create"></a> [subnet\_create](#input\_subnet\_create) | Whether to create a new subnet within the Virtual Network. | `bool` | `true` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet to create if `subnet_create` is true, or to use. | `string` | `"runners"` | no |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | The password for the administrator user. Either `vm_admin_password` or `vm_ssh_public_key` must be provided. | `string` | `null` | no |
| <a name="input_vm_admin_ssh_public_key"></a> [vm\_admin\_ssh\_public\_key](#input\_vm\_admin\_ssh\_public\_key) | The SSH public key for the administrator user. Example: `file("~/.ssh/id_rsa.pub")`. Either `vm_admin_password` or `vm_ssh_public_key` must be provided. | `string` | `null` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | The administrator username for the VM instances. | `string` | `"azdo"` | no |
| <a name="input_vm_disk_size_gb"></a> [vm\_disk\_size\_gb](#input\_vm\_disk\_size\_gb) | Size for the primary disk of the VMs, in Gb | `number` | `50` | no |
| <a name="input_vm_identity_name"></a> [vm\_identity\_name](#input\_vm\_identity\_name) | The name of the User Assigned Identity for the VMs. When null, it defaults to the `name` variable followed by `-id`. | `string` | `null` | no |
| <a name="input_vm_image_id"></a> [vm\_image\_id](#input\_vm\_image\_id) | The full resource ID of the custom image to use for the VMs. When null, and `vm_image_name` is not null, value is /subscriptions/${subscription\_id}/resourceGroups/${resource\_group\_name}/providers/Microsoft.Compute/images/${vm\_image\_name} | `string` | `null` | no |
| <a name="input_vm_image_name"></a> [vm\_image\_name](#input\_vm\_image\_name) | The name of the custom image to use for the VMs. The image is expected to be in the same resource group. | `string` | `null` | no |
| <a name="input_vm_init_instances"></a> [vm\_init\_instances](#input\_vm\_init\_instances) | The initial number of instances in the VMSS. Usually 0 as Azure DevOps manages the capacity. | `number` | `0` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The base name for the Virtual Machine instances. When null, it defaults to the `name` variable followed by `-vm`. | `string` | `null` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | The SKU (size) of the Virtual Machine Scale Set instances. | `string` | `"Standard_D4s_v5"` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_artifacts_download_example"></a> [artifacts\_download\_example](#output\_artifacts\_download\_example) | n/a |
| <a name="output_artifacts_mount_path"></a> [artifacts\_mount\_path](#output\_artifacts\_mount\_path) | n/a |
| <a name="output_artifacts_storage_account_name"></a> [artifacts\_storage\_account\_name](#output\_artifacts\_storage\_account\_name) | n/a |
| <a name="output_packer_pkrvars"></a> [packer\_pkrvars](#output\_packer\_pkrvars) | n/a |
<!-- END_TF_DOCS -->

### Generate this documentation
```shell
terraform-docs markdown table --output-file README.md --indent 3 .
```
