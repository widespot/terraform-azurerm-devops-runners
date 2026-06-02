# Register a VM Scale Set as an Elastic runner pool in AzureDevOps

For using this module, both the AzureRM provider and the Azure DevOps provider must be poiting at the same tenant,
and the account used to run Terraform must have the necessary permissions to:
* create Azure DevOps project resources
* **and** have Contributor role on the Azure subscription or Resource group where the VM Scale Set is deployed

> **SECURITY WARNING** about Azure DevOps auto registration in Azure Cloud
> 
> Under the hood, when creating an automatic Service Connection from Azure DevOps to Azure Cloud,
> Azure DevOps will leverage the permission of the user executing the command to create App Registrations, Identities and Roles assignments in Azure Cloud so that
> Azure DevOps can do much more than just driving a single VM Scale Set. It indeed end up being assigned to a Contributor role on the whole subscription 
> (or limited to the `resource_group` if provided).
> 
> We therefore strongly recommend not to use Azure DevOps auto registration in production environments (both from terraform and the web portal).



## Documentation
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | >= 1.0.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | >= 1.0.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

### Modules

No modules.

### Resources

| Name | Type |
| ---- | ---- |
| [azuredevops_elastic_pool.runners_pool](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/elastic_pool) | resource |
| [azuredevops_serviceendpoint_azurerm.service_endpoint](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm) | resource |
| [terraform_data.azure_vmss_id](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [azuredevops_project.project](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) | data source |
| [azuredevops_serviceendpoint_azurerm.service_endpoint](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/serviceendpoint_azurerm) | data source |
| [azurerm_subscription.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azure_vmss_id"></a> [azure\_vmss\_id](#input\_azure\_vmss\_id) | Required when `runner_pool_create` is true | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name of the project. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The id of the Azure DevOps project where the resources are created. Required if `project_name` is not defined | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the Azure DevOps project where the resources are created. Required if `project_id` is not defined | `string` | `null` | no |
| <a name="input_runner_pool_create"></a> [runner\_pool\_create](#input\_runner\_pool\_create) | n/a | `bool` | `true` | no |
| <a name="input_runner_pool_name"></a> [runner\_pool\_name](#input\_runner\_pool\_name) | The name of the Azure DevOps elastic agent pool. If null, it defaults to the `name` variable. | `string` | `null` | no |
| <a name="input_runner_pool_size_max"></a> [runner\_pool\_size\_max](#input\_runner\_pool\_size\_max) | The maximum number of agents allowed in the elastic pool. | `number` | `2` | no |
| <a name="input_runner_pool_size_min"></a> [runner\_pool\_size\_min](#input\_runner\_pool\_size\_min) | The minimum number of idle agents Azure DevOps should keep warm. | `number` | `0` | no |
| <a name="input_runner_recycle_after_each_use"></a> [runner\_recycle\_after\_each\_use](#input\_runner\_recycle\_after\_each\_use) | Whether Azure DevOps should tear down and recreate the VM after every job execution. | `bool` | `false` | no |
| <a name="input_runner_ttl_minutes"></a> [runner\_ttl\_minutes](#input\_runner\_ttl\_minutes) | The number of minutes to wait before deleting excess idle agents. | `number` | `15` | no |
| <a name="input_service_connection_create"></a> [service\_connection\_create](#input\_service\_connection\_create) | Whether to create a new AzureRM service connection in Azure DevOps. | `bool` | `true` | no |
| <a name="input_service_connection_id"></a> [service\_connection\_id](#input\_service\_connection\_id) | Id of the Azure DevOps Service endpoint to use. When not provided, the id is taken from either the existing or a newly created `devops_service_endpoint_name` Service Endpoint, based on the `devops_service_endpoint_create` variable. | `string` | `null` | no |
| <a name="input_service_connection_name"></a> [service\_connection\_name](#input\_service\_connection\_name) | The name of the AzureRM service connection to use or to create. If null, it defaults to the `name` variable followed by `-endpoint`. | `string` | `null` | no |
| <a name="input_service_connection_resource_group"></a> [service\_connection\_resource\_group](#input\_service\_connection\_resource\_group) | Azure Resource group in the scope of the service connection. When not provided and Service Connection to be created, the scope is the whole subscription. | `string` | `null` | no |
| <a name="input_service_connection_subscription_id"></a> [service\_connection\_subscription\_id](#input\_service\_connection\_subscription\_id) | Id of the Azure Subscription in the scope of the service connection. When not provided and Service Connection to be created, the id of the current subscription is used | `string` | `null` | no |
| <a name="input_service_connection_subscription_name"></a> [service\_connection\_subscription\_name](#input\_service\_connection\_subscription\_name) | Name of the Azure Subscription in the scope of the service connection. When not provided and Service Connection to be created, the name of the `service_connection_subscription_id` or the current subscription is used. | `string` | `null` | no |
| <a name="input_service_connection_tenant_id"></a> [service\_connection\_tenant\_id](#input\_service\_connection\_tenant\_id) | Tenant id in the scope of the service connection. When not provided and Service Connection to be created, the ID of the tenant of the `service_connection_subscription_id` or the current subscription is used | `string` | `null` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_azure_vmss_id"></a> [azure\_vmss\_id](#output\_azure\_vmss\_id) | Azure Virtual Machine Scale Set resource ID attached to the runner pool. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Azure DevOps project ID used by this module. |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Azure DevOps project name provided to this module. |
| <a name="output_runner_pool_created"></a> [runner\_pool\_created](#output\_runner\_pool\_created) | Whether this module is configured to create the runner pool. |
| <a name="output_runner_pool_id"></a> [runner\_pool\_id](#output\_runner\_pool\_id) | ID of the Azure DevOps elastic runner pool when created; null otherwise. |
| <a name="output_runner_pool_name"></a> [runner\_pool\_name](#output\_runner\_pool\_name) | Name of the Azure DevOps elastic runner pool. |
| <a name="output_runner_pool_size_max"></a> [runner\_pool\_size\_max](#output\_runner\_pool\_size\_max) | Configured maximum number of runners allowed in the elastic pool. |
| <a name="output_runner_pool_size_min"></a> [runner\_pool\_size\_min](#output\_runner\_pool\_size\_min) | Configured minimum number of warm idle runners in the elastic pool. |
| <a name="output_runner_recycle_after_each_use"></a> [runner\_recycle\_after\_each\_use](#output\_runner\_recycle\_after\_each\_use) | Whether runners are recycled after each job execution. |
| <a name="output_runner_ttl_minutes"></a> [runner\_ttl\_minutes](#output\_runner\_ttl\_minutes) | Configured idle runner time-to-live in minutes before scale down. |
| <a name="output_service_connection_created"></a> [service\_connection\_created](#output\_service\_connection\_created) | Whether this module created the AzureRM service connection during apply. |
| <a name="output_service_connection_id"></a> [service\_connection\_id](#output\_service\_connection\_id) | ID of the AzureRM service connection used by the runner pool. |
| <a name="output_service_connection_name"></a> [service\_connection\_name](#output\_service\_connection\_name) | Name of the AzureRM service connection used or created by this module. |
| <a name="output_service_connection_resource_group"></a> [service\_connection\_resource\_group](#output\_service\_connection\_resource\_group) | Resource group scope configured on the service connection, if any. |
| <a name="output_service_connection_subscription_id"></a> [service\_connection\_subscription\_id](#output\_service\_connection\_subscription\_id) | Azure subscription ID associated with the service connection. |
| <a name="output_service_connection_subscription_name"></a> [service\_connection\_subscription\_name](#output\_service\_connection\_subscription\_name) | Azure subscription name associated with the service connection. |
| <a name="output_service_connection_tenant_id"></a> [service\_connection\_tenant\_id](#output\_service\_connection\_tenant\_id) | Azure tenant ID associated with the service connection. |
<!-- END_TF_DOCS -->

### Generate this documentation
```shell
terraform-docs markdown table --output-file README.md --indent 3 .
```
