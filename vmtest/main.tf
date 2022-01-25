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

resource "azurerm_network_interface" "vmnic1" {
  name                = "${azurerm_subnet.net1.name}-nic1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${azurerm_subnet.net1.name}-internal"
    subnet_id                     = azurerm_subnet.net1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "${azurerm_resource_group.rg.name}-vm1"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1ls"
  admin_username                  = "userone"
  admin_password                  = "User1pass"
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.vmnic1.id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_network_interface" "vmnic2" {
  name                = "${azurerm_subnet.net2.name}-nic2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${azurerm_subnet.net2.name}-internal"
    subnet_id                     = azurerm_subnet.net2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                            = "${azurerm_resource_group.rg.name}-vm2"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1ls"
  admin_username                  = "usertwo"
  admin_password                  = "User2pass"
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.vmnic2.id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
