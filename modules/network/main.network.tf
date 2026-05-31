locals {
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location != null ? var.resource_group_location : data.azurerm_resource_group.resource_group[0].location

  network_name_default = coalesce(var.network_name, "${var.name}-vnet")
  network_cidr         = var.network_create ? one(azurerm_virtual_network.network[0].address_space) : one(data.azurerm_virtual_network.network[0].address_space)
  network_name         = var.network_create ? azurerm_virtual_network.network[0].name : data.azurerm_virtual_network.network[0].name

  subnet_name_default = coalesce(var.subnet_name, "${var.name}-subnet")
  subnet_cidr_default = coalesce(var.subnet_cidr, cidrsubnet(local.network_cidr, 2, 0))
  subnet_name         = var.subnet_create ? azurerm_subnet.subnet[0].name : data.azurerm_subnet.subnet[0].name
  subnet_id           = var.subnet_create ? azurerm_subnet.subnet[0].id : data.azurerm_subnet.subnet[0].id

  nat_gateway_name_default = "${var.name}-nat"
}

data "azurerm_resource_group" "resource_group" {
  count = var.resource_group_location == null ? 1 : 0

  name = var.resource_group_name
}

resource "azurerm_virtual_network" "network" {
  count = var.network_create ? 1 : 0

  name                = local.network_name_default
  address_space       = [var.network_cidr]
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}
data "azurerm_virtual_network" "network" {
  count = var.network_create ? 0 : 1

  name                = local.network_name_default
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  count = var.subnet_create ? 1 : 0

  name                 = local.subnet_name_default
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.network_name
  address_prefixes     = [local.subnet_cidr_default]
}
data "azurerm_subnet" "subnet" {
  count = var.subnet_create ? 0 : 1

  name                 = local.subnet_name_default
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.network_name
}

resource "azurerm_public_ip" "nat" {
  count               = var.nat_gateway_create ? 1 : 0
  name                = "${local.nat_gateway_name_default}-ip"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat" {
  count               = var.nat_gateway_create ? 1 : 0
  name                = local.nat_gateway_name_default
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat" {
  count                = var.nat_gateway_create ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "nat" {
  count          = var.nat_gateway_create ? 1 : 0
  subnet_id      = local.subnet_id
  nat_gateway_id = azurerm_nat_gateway.nat[0].id
}

resource "azurerm_network_security_group" "subnet_nsg" {
  name                = "${local.subnet_name}-nsg"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "DenyInterSubnetTraffic"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  subnet_id                 = local.subnet_id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}
