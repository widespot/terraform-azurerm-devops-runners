# Azure DevOps Runner Scale Set Module

This module deploys and configures the core compute infrastructure for self-hosted Azure DevOps Elastic Runner Pools on Azure.

It provisions a Linux Virtual Machine Scale Set (VMSS) with the Azure Pipelines Agent extension, manages VM identities, mounts optional shared Azure Blob storage containers using Blobfuse2, and provisions optional standalone development VMs for testing and debugging runner images. Additionally, it supports fine-grained Workload Identity Federation (OIDC) between Azure DevOps and Azure to operate the runner VMSS under the principle of least privilege.

## Features

* **Azure DevOps VM Scale Set**: Provisions a Linux VMSS integrated with the `Microsoft.Azure.DevOps.Pipelines.Agent` extension to enable automatic scaling and orchestration by Azure DevOps Elastic Pools.
* **Workload Identity Federation & Least-Privilege RBAC**: When provided with Azure DevOps token federation details (`devops_token_issuer` and `devops_token_subject`), provisions an Azure AD Application, Federated Identity Credential, and custom RBAC role definitions (`AzDO VMSS Discovery` and `AzDO VMSS Operator`) scoped strictly to the scale set rather than granting subscription-wide Contributor permissions.
* **Shared Storage Mounting via Blobfuse2**: Automatically generates cloud-init configurations to mount Azure Storage Blob containers across runner instances and dev VMs in read-only or read-write mode.
* **Standalone Development VMs**: Optional standalone VM instances with public IPs and Network Security Groups (allowing SSH and VNC access) to test, inspect, or troubleshoot runner images before deploying to the scale set.
* **Managed Identity Support**: Creates or links a User-Assigned Managed Identity used by the scale set instances to access Azure resources (such as storage accounts).

## Usage Examples

### Basic Runner Pool

```hcl
module "runner" {
  source = "./modules/runner"

  name                = "build-runner"
  resource_group_name = "runners-rg"
  subnet_id           = module.network.subnet_id

  vm_image_name       = "custom-ubuntu-runner-2024"
  vm_size             = "Standard_D4s_v5"
  vm_admin_username   = "azdo"
  vm_admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
}
```

### Runner Pool with Workload Identity Federation & Storage Mounts

```hcl
module "runner" {
  source = "./modules/runner"

  name                = "prod-runner"
  resource_group_name = "runners-rg"
  subnet_id           = module.network.subnet_id

  vm_image_name       = "custom-ubuntu-runner-2024"
  vm_size             = "Standard_D8s_v5"
  vm_admin_username   = "azdo"
  vm_admin_ssh_public_key = file("~/.ssh/id_rsa.pub")

  # Azure DevOps Workload Identity Federation
  devops_organization          = "my-azdo-org"
  devops_project_name          = "my-project"
  devops_service_connection_id = "00000000-0000-0000-0000-000000000000"
  devops_token_issuer          = "https://vststoken.dev.azure.com/00000000-0000-0000-0000-000000000000"
  devops_token_subject         = "sc://my-azdo-org/my-project/my-service-connection"

  # Shared storage mount
  registry_storage_mounts = {
    "artifacts_storage" = {
      container_name = "cache"
      mount_path     = "/mnt/cache"
      read_only      = true
    }
  }

  # Optional Dev VM for interactive image debugging
  dev_vms_count = 1
}
```

## Documentation
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.49 |

### Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.49 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

### Modules

No modules.

### Resources

| Name | Type |
| ---- | ---- |
| [azuread_application_federated_identity_credential.runner](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_registration.runner](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_registration) | resource |
| [azuread_service_principal.runner](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_linux_virtual_machine_scale_set.runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_network_interface.dev_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.dev_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.dev_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.dev_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.azdo_vmss_discovery](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.azdo_vmss_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.devops](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.azdo_vmss_discovery](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.azdo_vmss_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_machine.dev_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine_scale_set_extension.extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [terraform_data.cloud_init](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_user_assigned_identity.runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dev_vm_admin_password"></a> [dev\_vm\_admin\_password](#input\_dev\_vm\_admin\_password) | The password for the administrator user. Default is `vm_admin_username` | `string` | `null` | no |
| <a name="input_dev_vm_admin_ssh_public_key"></a> [dev\_vm\_admin\_ssh\_public\_key](#input\_dev\_vm\_admin\_ssh\_public\_key) | Public ssh key for the admin user on the dev machines. Default is `vm_admin_ssh_public_key` | `string` | `null` | no |
| <a name="input_dev_vm_admin_username"></a> [dev\_vm\_admin\_username](#input\_dev\_vm\_admin\_username) | Admin username of the dev vms. Default is `vm_admin_username` | `string` | `null` | no |
| <a name="input_dev_vm_disk_size_gb"></a> [dev\_vm\_disk\_size\_gb](#input\_dev\_vm\_disk\_size\_gb) | Size for the primary disk of the dev VMs, in Gb. Default value is `vm_disk_size_gb` | `number` | `null` | no |
| <a name="input_dev_vm_image_id"></a> [dev\_vm\_image\_id](#input\_dev\_vm\_image\_id) | Image id for the dev machine. When null, value is `vm_image_id` | `string` | `null` | no |
| <a name="input_dev_vm_image_name"></a> [dev\_vm\_image\_name](#input\_dev\_vm\_image\_name) | The name of the custom image to use for the VMs. The image is expected to be in the same resource group. When null, value is `vm_image_name` | `string` | `null` | no |
| <a name="input_dev_vm_name_prefix"></a> [dev\_vm\_name\_prefix](#input\_dev\_vm\_name\_prefix) | Prefix for the dev vm name | `string` | `null` | no |
| <a name="input_dev_vm_size"></a> [dev\_vm\_size](#input\_dev\_vm\_size) | Size of the development VMs. Default is the value of `vm_size` | `string` | `null` | no |
| <a name="input_dev_vms_count"></a> [dev\_vms\_count](#input\_dev\_vms\_count) | The number of standalone development VMs to create for testing the image. | `number` | `0` | no |
| <a name="input_devops_agent_enable_script_version"></a> [devops\_agent\_enable\_script\_version](#input\_devops\_agent\_enable\_script\_version) | n/a | `string` | `"17"` | no |
| <a name="input_devops_agent_version"></a> [devops\_agent\_version](#input\_devops\_agent\_version) | Version of the DevOps agent to install via a scale set extension on the instances. Url is https://download.agent.dev.azure.com/agent/${devops_agent_version}/vsts-agent-linux-x64-${devops_agent_version}.tar.gz | `string` | `"4.273.0"` | no |
| <a name="input_devops_organization"></a> [devops\_organization](#input\_devops\_organization) | Name of the DevOps organization using the VM scale set. The value has no functional meaning and is only used to populate names and descriptions. The connection is only based on the `devops_token_issuer` and `devops_token_subject`. Required when `devops_token_subject` is used. | `string` | `null` | no |
| <a name="input_devops_project_name"></a> [devops\_project\_name](#input\_devops\_project\_name) | Name of the DevOps project using the VM scale set. The value has no functional meaning and is only used to populate names and descriptions. The connection is only based on the `devops_token_issuer` and `devops_token_subject`. Required when `devops_token_subject` is used. | `string` | `null` | no |
| <a name="input_devops_service_connection_id"></a> [devops\_service\_connection\_id](#input\_devops\_service\_connection\_id) | ID of the DevOps service connection driving the VM scale set. The value has no functional meaning and is only used to populate names and descriptions. The connection is only based on the `devops_token_issuer` and `devops_token_subject`. Required when `devops_token_subject` is used. | `string` | `null` | no |
| <a name="input_devops_token_issuer"></a> [devops\_token\_issuer](#input\_devops\_token\_issuer) | Devops token issuer allowed to drive the VM scale set. Required when `devops_token_subject` is used. | `string` | `null` | no |
| <a name="input_devops_token_subject"></a> [devops\_token\_subject](#input\_devops\_token\_subject) | Devops token subject allowed to drive the VM scale set. Required when `devops_token_issuer` is used. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the runner pool and associated resources. | `string` | n/a | yes |
| <a name="input_registry_storage_mounts"></a> [registry\_storage\_mounts](#input\_registry\_storage\_mounts) | List of Storage Account container to mount in both the runner and dev VM instances. The name of the Storage account to use is the key of the entries in the map. | <pre>map(object({<br/>    mount_path     = optional(string, null)<br/>    cache_path     = optional(string, null)<br/>    read_only      = optional(bool, true)<br/>    container_name = string<br/>  }))</pre> | `{}` | no |
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

| Name | Description |
| ---- | ----------- |
| <a name="output_devops_app_registration_client_id"></a> [devops\_app\_registration\_client\_id](#output\_devops\_app\_registration\_client\_id) | n/a |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | n/a |
| <a name="output_subscription_name"></a> [subscription\_name](#output\_subscription\_name) | n/a |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | n/a |
| <a name="output_vm_identity_id"></a> [vm\_identity\_id](#output\_vm\_identity\_id) | n/a |
| <a name="output_vm_identity_name"></a> [vm\_identity\_name](#output\_vm\_identity\_name) | n/a |
| <a name="output_vm_identity_principal_id"></a> [vm\_identity\_principal\_id](#output\_vm\_identity\_principal\_id) | n/a |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | n/a |
<!-- END_TF_DOCS -->

### Generate this documentation
```shell
terraform-docs markdown table --output-file README.md --indent 3 .
```
