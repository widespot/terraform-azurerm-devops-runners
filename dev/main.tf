
# terraform import azurerm_virtual_machine_scale_set_extension.example /subscriptions/083e56a7-a090-4ad2-b62f-13b7e69fc648/resourceGroups/tempo-runner-rg/providers/Microsoft.Compute/virtualMachineScaleSets/tempo-runner-vmss/extensions/Microsoft.Azure.DevOps.Pipelines.Agent
resource "azurerm_virtual_machine_scale_set_extension" "example" {
  name                         = "Microsoft.Azure.DevOps.Pipelines.Agent"
  virtual_machine_scale_set_id = "/subscriptions/083e56a7-a090-4ad2-b62f-13b7e69fc648/resourceGroups/tempo-runner-rg/providers/Microsoft.Compute/virtualMachineScaleSets/tempo-runner-vmss"
  publisher                    = "Microsoft.VisualStudio.Services"
  type                         = "TeamServicesAgentLinux"
  type_handler_version         = "1.26"
  settings = jsonencode({
     agentDownloadUrl        = "https://download.agent.dev.azure.com/agent/4.273.0/vsts-agent-linux-x64-4.273.0.tar.gz"
     agentFolder             = "/agent"
     enableScriptDownloadUrl = "https://vstsagenttools.blob.core.windows.net/tools/ElasticPools/Linux/17/enableagent.sh"
     isPipelinesAgent        = true
  })
  auto_upgrade_minor_version = false
  automatic_upgrade_enabled = false
  provision_after_extensions = []
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
  subscription_id = "083e56a7-a090-4ad2-b62f-13b7e69fc648"
}

