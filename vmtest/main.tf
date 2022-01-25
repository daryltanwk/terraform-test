terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

# Resource Group

resource "azurerm_resource_group" "rg" {
  location = "Southeast Asia"
  name     = "test-dt"
}

# Networking

resource "azurerm_virtual_network" "vnet" {
  name = "${azurerm_resource_group.rg.name}-vnet"

  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "net1" {
  name                 = "${azurerm_resource_group.rg.name}-net1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "net2" {
  name                 = "${azurerm_resource_group.rg.name}-net2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "net3" {
  name                 = "${azurerm_resource_group.rg.name}-net3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_route_table" "route-table" {
  name                = "${azurerm_resource_group.rg.name}-route-table"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_route_table_association" "net1-assoc" {
  route_table_id = azurerm_route_table.route-table.id
  subnet_id      = azurerm_subnet.net1.id
}

resource "azurerm_subnet_route_table_association" "net2-assoc" {
  route_table_id = azurerm_route_table.route-table.id
  subnet_id      = azurerm_subnet.net2.id
}
resource "azurerm_subnet_route_table_association" "net3-assoc" {
  route_table_id = azurerm_route_table.route-table.id
  subnet_id      = azurerm_subnet.net3.id
}

# Virtual Machines

# resource "azurerm_virtual_machine" "db" {

# }

# resource "azurerm_virtual_machine" "app" {

# }

# resource "azurerm_virtual_machine" "web" {

# }
