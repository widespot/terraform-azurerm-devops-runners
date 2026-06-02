For using this module, the user executing terraform must be able, with no tenant switch to both
* create Azure DevOps project resources
* **and** create Azure Cloud identity

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

### Modules

No modules.

### Resources

| Name | Type |
| ---- | ---- |
| [azuredevops_elastic_pool.runners_pool](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/elastic_pool) | resource |
| [azuredevops_serviceendpoint_azurerm.service_endpoint](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm) | resource |
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

No outputs.
<!-- END_TF_DOCS -->

### Generate this documentation
```shell
terraform-docs markdown table --output-file README.md --indent 3 .
```
