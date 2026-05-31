locals {
  dev_vm_image_id = try(coalesce(var.dev_vm_image_id, local.vm_image_id), null)
}
resource "azurerm_network_interface" "dev_network_interface" {
  count = local.dev_vm_image_id == null ? 0 : var.dev_vms_count

  name                = "${local.vm_name}-${count.index}-nic"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.dev_ip[count.index].id
  }
}

resource "azurerm_public_ip" "dev_ip" {
  count = local.dev_vm_image_id == null ? 0 : var.dev_vms_count

  allocation_method   = "Static"
  location            = local.resource_group_location
  name                = "${local.vm_name}-${count.index}-ip"
  resource_group_name = local.resource_group_name
}

resource "azurerm_virtual_machine" "dev_vm" {
  count = local.dev_vm_image_id == null ? 0 : var.dev_vms_count

  name = "${local.vm_name}-${count.index}"

  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  network_interface_ids = [azurerm_network_interface.dev_network_interface[count.index].id]
  vm_size               = coalesce(var.dev_vm_size, var.vm_size)

  storage_image_reference {
    id = local.dev_vm_image_id
  }

  delete_os_disk_on_termination = true
  storage_os_disk {
    name              = "${local.vm_name}-${count.index}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = var.vm_disk_size_gb
  }
  os_profile {
    computer_name  = "${local.vm_name}-${count.index}"
    admin_username = var.vm_admin_username
    admin_password = var.dev_vm_admin_password
    custom_data    = local.artifacts_blobfuse_mount_enabled ? base64encode(local.artifacts_blobfuse_cloud_init) : null
  }
  os_profile_linux_config {
    disable_password_authentication = var.dev_vm_admin_password != null ? false : true

    dynamic "ssh_keys" {
      for_each = var.vm_ssh_public_key == null ? [] : [0]
      content {
        key_data = var.vm_ssh_public_key
        path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
      }
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.runner.id]
  }
}

resource "azurerm_network_security_group" "dev_nsg" {
  count = local.dev_vm_image_id == null || var.dev_vms_count == 0 ? 0 : 1

  name                = "${local.vm_name}-dev-nsg"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VNC"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5900-6000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "dev_nsg_association" {
  count = local.dev_vm_image_id == null ? 0 : var.dev_vms_count

  network_interface_id      = azurerm_network_interface.dev_network_interface[count.index].id
  network_security_group_id = azurerm_network_security_group.dev_nsg[0].id
}
