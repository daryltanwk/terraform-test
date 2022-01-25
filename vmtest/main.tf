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

resource "azurerm_public_ip" "pubip" {
  name                = "${azurerm_resource_group.rg.name}-pubip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
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
    public_ip_address_id          = azurerm_public_ip.pubip.id
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


resource "azurerm_network_interface" "vmnic3" {
  name                = "${azurerm_subnet.net3.name}-nic3"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${azurerm_subnet.net3.name}-internal"
    subnet_id                     = azurerm_subnet.net3.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm3" {
  name                            = "${azurerm_resource_group.rg.name}-vm3"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1ls"
  admin_username                  = "userthree"
  admin_password                  = "User3pass"
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.vmnic3.id
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

# Security Groups

resource "azurerm_network_security_group" "secgrp" {
  name                = "${azurerm_resource_group.rg.name}-secgrp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allowSSH" {
  name                        = "${azurerm_resource_group.rg.name}-allowSSH"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.secgrp.name
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.1.0/24"
  access                      = "Allow"
  priority                    = 100
  direction                   = "Inbound"

}

resource "azurerm_network_interface_security_group_association" "secgrp-nic1assoc" {
  network_interface_id      = azurerm_network_interface.vmnic1.id
  network_security_group_id = azurerm_network_security_group.secgrp.id
}

resource "azurerm_network_interface_security_group_association" "secgrp-nic2assoc" {
  network_interface_id      = azurerm_network_interface.vmnic2.id
  network_security_group_id = azurerm_network_security_group.secgrp.id
}

resource "azurerm_network_interface_security_group_association" "secgrp-nic3assoc" {
  network_interface_id      = azurerm_network_interface.vmnic3.id
  network_security_group_id = azurerm_network_security_group.secgrp.id
}
# Outputs

data "azurerm_public_ip" "ext-ip" {
  name                = azurerm_public_ip.pubip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "pubip" {
  value = data.azurerm_public_ip.ext-ip.ip_address
}
