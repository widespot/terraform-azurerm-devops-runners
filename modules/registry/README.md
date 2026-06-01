## Documentation
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.49.0 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.49.0 |

### Modules

No modules.

### Resources

| Name | Type |
| ---- | ---- |
| [azurerm_role_assignment.runner_storage_reader](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/storage_account) | resource |
| [azurerm_storage_blob.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/resources/storage_container) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.49.0/docs/data-sources/resource_group) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_artifacts"></a> [artifacts](#input\_artifacts) | A map of artifacts to upload to the storage container. The key is the blob name, and the value is an object with `source` (path to local file) and optional `content_type`. | <pre>map(object({<br/>    source       = string<br/>    content_type = optional(string, "application/octet-stream")<br/>  }))</pre> | `{}` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the storage container for artifacts. | `string` | `"artifacts"` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location of the resource group use. If not provided, the location is dynamically loaded thanks to a data block | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to use | `string` | n/a | yes |
| <a name="input_runner_principal_ids"></a> [runner\_principal\_ids](#input\_runner\_principal\_ids) | Map of runner key to User Managed Identity of the runners VM allowed to read the artifacts | `map(string)` | n/a | yes |
| <a name="input_storage_account_create"></a> [storage\_account\_create](#input\_storage\_account\_create) | Whether to create the artifact storage account and container. | `bool` | `true` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account for artifacts. If null, it defaults to the `name` variable (sanitized). | `string` | n/a | yes |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
<!-- END_TF_DOCS -->

### Generate this documentation
```shell
terraform-docs markdown table --output-file README.md --indent 3 .
```
