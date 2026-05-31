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
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | >= 1.0.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.49.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

### Modules

No modules.

### Resources

| Name | Type |
| ---- | ---- |
| [azuredevops_elastic_pool.runners_pool](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/elastic_pool) | resource |
| [azuredevops_serviceendpoint_azurerm.service_endpoint](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm) | resource |
| [azurerm_linux_virtual_machine_scale_set.runner](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_network_interface.dev_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.dev_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.dev_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.dev_ip](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/public_ip) | resource |
| [azurerm_user_assigned_identity.runner](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_machine.dev_vm](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/virtual_machine) | resource |
| [terraform_data.cloud_init](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [azuredevops_project.project](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) | data source |
| [azuredevops_serviceendpoint_azurerm.service_endpoint](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/serviceendpoint_azurerm) | data source |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/data-sources/subscription) | data source |
| [azurerm_user_assigned_identity.runner](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/data-sources/user_assigned_identity) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dev_vm_admin_password"></a> [dev\_vm\_admin\_password](#input\_dev\_vm\_admin\_password) | The password for the administrator user. Default is `vm_admin_username` | `string` | `null` | no |
| <a name="input_dev_vm_admin_ssh_public_key"></a> [dev\_vm\_admin\_ssh\_public\_key](#input\_dev\_vm\_admin\_ssh\_public\_key) | Public ssh key for the admin user on the dev machines. Default is `vm_admin_ssh_public_key` | `string` | `null` | no |
| <a name="input_dev_vm_admin_username"></a> [dev\_vm\_admin\_username](#input\_dev\_vm\_admin\_username) | Admin username of the dev vms. Default is `vm_admin_username` | `string` | `null` | no |
| <a name="input_dev_vm_disk_size_gb"></a> [dev\_vm\_disk\_size\_gb](#input\_dev\_vm\_disk\_size\_gb) | Size for the primary disk of the dev VMs, in Gb | `number` | `null` | no |
| <a name="input_dev_vm_image_id"></a> [dev\_vm\_image\_id](#input\_dev\_vm\_image\_id) | Image id for the dev machine. When null, value is `vm_image_id` | `string` | `null` | no |
| <a name="input_dev_vm_image_name"></a> [dev\_vm\_image\_name](#input\_dev\_vm\_image\_name) | The name of the custom image to use for the VMs. The image is expected to be in the same resource group. | `string` | `null` | no |
| <a name="input_dev_vm_name_prefix"></a> [dev\_vm\_name\_prefix](#input\_dev\_vm\_name\_prefix) | Prefix for the dev vm name | `string` | `null` | no |
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
| <a name="input_name"></a> [name](#input\_name) | Base name for the runner pool and associated resources. | `string` | n/a | yes |
| <a name="input_registry_storage_mounts"></a> [registry\_storage\_mounts](#input\_registry\_storage\_mounts) | The name of the storage account for artifacts. If null, it defaults to the `name` variable (sanitized). | <pre>map(object({<br/>    mount_path = optional(string, null) # /mnt/artifacts/each.key<br/>    cache_path = optional(string, null) # /var/cache/blobfuse2/<br/>    read_only = optional(bool, true)<br/>    container_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location of the resource group use. If not provided, the location is dynamically loaded thanks to a data block | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to use | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet where to deploy all the runners | `string` | n/a | yes |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | The password for the administrator user. Either `vm_admin_password` or `vm_ssh_public_key` must be provided. | `string` | `null` | no |
| <a name="input_vm_admin_ssh_public_key"></a> [vm\_admin\_ssh\_public\_key](#input\_vm\_admin\_ssh\_public\_key) | The SSH public key for the administrator user. Example: `file("~/.ssh/id_rsa.pub")`. Either `vm_admin_password` or `vm_ssh_public_key` must be provided. | `string` | `null` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | The administrator username for the VM instances. | `string` | `"azdo"` | no |
| <a name="input_vm_disk_size_gb"></a> [vm\_disk\_size\_gb](#input\_vm\_disk\_size\_gb) | Size for the primary disk of the VMs, in Gb | `number` | `50` | no |
| <a name="input_vm_identity_create"></a> [vm\_identity\_create](#input\_vm\_identity\_create) | Should the vm identity be created if no `vm_identity_id` is provided | `bool` | `true` | no |
| <a name="input_vm_identity_id"></a> [vm\_identity\_id](#input\_vm\_identity\_id) | Id of the existing identity to assign to the runner VMs and dev VMs | `string` | `null` | no |
| <a name="input_vm_identity_name"></a> [vm\_identity\_name](#input\_vm\_identity\_name) | The name of the VM User Assigned Identity to create if `vm_identity_id` is not provided. When null, it defaults to the `name` variable followed by `-id`. | `string` | `null` | no |
| <a name="input_vm_image_id"></a> [vm\_image\_id](#input\_vm\_image\_id) | The full resource ID of the custom image to use for the VMs. When null, and `vm_image_name` is not null, value is /subscriptions/${subscription\_id}/resourceGroups/${resource\_group\_name}/providers/Microsoft.Compute/images/${vm\_image\_name} | `string` | `null` | no |
| <a name="input_vm_image_name"></a> [vm\_image\_name](#input\_vm\_image\_name) | The name of the custom image to use for the VMs. The image is expected to be in the same resource group. | `string` | `null` | no |
| <a name="input_vm_init_instances"></a> [vm\_init\_instances](#input\_vm\_init\_instances) | The initial number of instances in the VMSS. Usually 0 as Azure DevOps manages the capacity. | `number` | `0` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The base name for the Virtual Machine instances. When null, it defaults to the `name` variable followed by `-vm`. | `string` | `null` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | The SKU (size) of the Virtual Machine Scale Set instances. | `string` | `"Standard_D4s_v5"` | no |

### Outputs

No outputs.
<!-- END_TF_DOCS -->

### Generate this documentation
```shell
terraform-docs markdown table --output-file README.md --indent 3 .
```
