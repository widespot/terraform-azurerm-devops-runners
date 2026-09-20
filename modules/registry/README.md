# Artifact Storage & Registry Module

This module manages Azure Blob Storage accounts and containers designed to be used by Azure DevOps runner pools for caching, 
build artifact storage, and shared file distribution.

It supports creating new storage accounts and containers or integrating with existing ones, uploading local files/artifacts as blobs, 
and provisioning Azure RBAC role assignments for runner User-Assigned Managed Identities with least-privilege access (`Storage Blob Data Reader` or `Storage Blob Data Contributor`).

## Features

* **Flexible Storage Provisioning**: Creates dedicated Azure Storage Accounts (Standard LRS, TLS 1.2, private nested items) and Blob containers, or references existing storage accounts and containers via ID or name.
* **Runner Managed Identity RBAC**: Automatically grants least-privilege Azure RBAC roles (`Storage Blob Data Reader` for read-only or `Storage Blob Data Contributor` for read-write access) to runner User-Assigned Managed Identities.
* **Artifact Uploads**: Provisions and uploads static files or scripts into the storage container at deployment time via the `artifacts` input map.
* **Blobfuse2 Compatibility**: Outputs storage account and container details designed to integrate seamlessly with the runner module's Blobfuse2 storage mounting configuration.

## Usage Examples

### Standalone Storage Account & Container

```hcl
module "registry" {
  source = "./modules/registry"

  resource_group_name  = "runners-rg"
  storage_account_name = "runnerartifactssa"
  container_name       = "build-cache"
}
```

### Storage with Runner Identity Access & Artifact Uploads

```hcl
module "registry" {
  source = "./modules/registry"

  resource_group_name  = "runners-rg"
  storage_account_name = "runnerartifactssa"
  container_name       = "artifacts"

  # Grant access to runner managed identities
  runner_identity_access = {
    "build-runner" = {
      principal_id = azurerm_user_assigned_identity.runner["build-runner"].principal_id
      read_only    = true
    }
    "deploy-runner" = {
      principal_id = azurerm_user_assigned_identity.runner["deploy-runner"].principal_id
      read_only    = false
    }
  }

  # Upload pre-seeded files/tools to the container
  artifacts = {
    "scripts/init.sh" = {
      source       = "${path.module}/scripts/init.sh"
      content_type = "text/x-shellscript"
    }
  }
}
```

### Using an Existing Storage Account

```hcl
module "registry" {
  source = "./modules/registry"

  resource_group_name    = "runners-rg"
  storage_account_create = false
  storage_account_name   = "existingstorageacct"
  container_name         = "shared-cache"
  container_create       = true

  runner_identity_access = {
    "build-runner" = {
      principal_id = azurerm_user_assigned_identity.runner["build-runner"].principal_id
      read_only    = true
    }
  }
}
```

## Documentation
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.77 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.77 |

### Modules

No modules.

### Resources

| Name | Type |
| ---- | ---- |
| [azurerm_role_assignment.runner_storage_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_blob.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_storage_container.artifacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_artifacts"></a> [artifacts](#input\_artifacts) | A map of artifacts to upload to the storage container. The key is the blob name, and the value is an object with `source` (path to local file) and optional `content_type`. | <pre>map(object({<br/>    source       = string<br/>    content_type = optional(string, "application/octet-stream")<br/>  }))</pre> | `{}` | no |
| <a name="input_container_create"></a> [container\_create](#input\_container\_create) | Whether container should be created or not. This value is ignored if `container_id` is provided | `bool` | `true` | no |
| <a name="input_container_id"></a> [container\_id](#input\_container\_id) | Id of an existing container | `string` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the storage container for artifacts. | `string` | `"artifacts"` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location of the resource group use. If not provided, the location is dynamically loaded thanks to a data block | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to use | `string` | n/a | yes |
| <a name="input_runner_identity_access"></a> [runner\_identity\_access](#input\_runner\_identity\_access) | Map of runner key to User Managed Identity of the runners VM allowed to read the artifacts | <pre>map(object({<br/>    principal_id = string<br/>    read_only    = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_storage_account_create"></a> [storage\_account\_create](#input\_storage\_account\_create) | Whether to create the artifact storage account and container. | `bool` | `true` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | n/a | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account for artifacts. If null, it defaults to the `name` variable (sanitized). | `string` | `null` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | n/a |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
<!-- END_TF_DOCS -->

### Generate this documentation
```shell
terraform-docs markdown table --output-file README.md --indent 3 .
```
