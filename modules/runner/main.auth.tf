locals {
  devops_manual_registration = var.devops_token_issuer != null && var.devops_token_subject != null
}

resource "azuread_application_registration" "runner" {
  count = local.devops_manual_registration ? 1 : 0

  display_name = "${var.devops_organization}-${var.devops_project}-${var.devops_service_connection_id}"
  # When importing the one created by AzDo, this value is set to 0. But 0 is not allowed when creating from Terraform :(
  requested_access_token_version = 1
  sign_in_audience = "AzureADMyOrg"
  notes = "Managed by Terraform"
}

resource "azuread_application_federated_identity_credential" "runner" {
  count = local.devops_manual_registration ? 1 : 0

  application_id = azuread_application_registration.runner[0].id
  display_name   = var.devops_service_connection_id
  description    = "Federation for Service Connection ${var.name} in https://dev.azure.com/${var.devops_organization}/${var.devops_project}/_settings/adminservices?resourceId=${var.devops_service_connection_id}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.devops_token_issuer
  subject        = var.devops_token_subject
}

resource "azuread_service_principal" "runner" {
  count = local.devops_manual_registration ? 1 : 0

  client_id = azuread_application_registration.runner[0].client_id
}

resource "azurerm_role_definition" "azdo_vmss_discovery" {
  count = local.devops_manual_registration ? 1 : 0

  name        = "AzDO VMSS Discovery ${var.name}"
  scope       = data.azurerm_subscription.subscription.id
  description = "Allows Azure DevOps to discover VM scale sets."

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachineScaleSets/read"
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.subscription.id
  ]
}

resource "azurerm_role_definition" "azdo_vmss_operator" {
  count = local.devops_manual_registration ? 1 : 0

  name        = "AzDO VMSS Operator ${var.name}"
  scope = azurerm_linux_virtual_machine_scale_set.runner[0].id
  description = "Allows Azure DevOps to operate one VM scale set."

  # See more in https://learn.microsoft.com/en-us/azure/role-based-access-control/permissions/compute
  permissions {
    actions = [
      "Microsoft.Compute/virtualMachineScaleSets/read",
      # TODO remove this one as it allows new VMSS creation
      "Microsoft.Compute/virtualMachineScaleSets/write",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/delete",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/reimage/action",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/redeploy/action",
      "Microsoft.Compute/virtualMachineScaleSets/extensions/read",
      "Microsoft.Compute/virtualMachineScaleSets/extensions/write",
      "Microsoft.Compute/virtualMachineScaleSets/extensions/delete",
    ]
  }

  assignable_scopes = [
    azurerm_linux_virtual_machine_scale_set.runner[0].id
  ]
}


resource "azurerm_role_assignment" "devops" {
  count = local.devops_manual_registration ? 1 : 0

  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.runner[0].object_id
}


resource "azurerm_role_assignment" "azdo_vmss_discovery" {
  count = local.devops_manual_registration ? 1 : 0

  scope              = data.azurerm_subscription.subscription.id
  role_definition_id = azurerm_role_definition.azdo_vmss_discovery[0].role_definition_resource_id
  principal_id       = azuread_service_principal.runner[0].object_id
}

resource "azurerm_role_assignment" "azdo_vmss_operator" {
  count = local.devops_manual_registration ? 1 : 0

  scope              = azurerm_linux_virtual_machine_scale_set.runner[0].id
  role_definition_id = azurerm_role_definition.azdo_vmss_operator[0].role_definition_resource_id
  principal_id       = azuread_service_principal.runner[0].object_id
}
