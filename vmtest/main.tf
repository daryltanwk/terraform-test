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
  name     = "${local.project_name}-${local.user}"
}

# Networking

resource "azurerm_virtual_network" "vnet" {
  name = "${azurerm_resource_group.rg.name}-vnet"

  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "subnets" {
  for_each = { for idx, clus in var.cluster_names : clus => idx }

  name                 = "${azurerm_resource_group.rg.name}-subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${each.value + 1}.0/24"]
}

resource "azurerm_public_ip" "pubip" {
  name                = "${azurerm_resource_group.rg.name}-pubip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

# Virtual Machines

resource "azurerm_network_interface" "vmnics" {
  for_each = { for idx, clus in var.cluster_names : clus => idx }

  name                = "${azurerm_subnet.subnets[each.key].name}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${azurerm_subnet.subnets[each.key].name}-internal"
    subnet_id                     = azurerm_subnet.subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value == 0 ? azurerm_public_ip.pubip.id : null
  }
}

resource "azurerm_linux_virtual_machine" "vms" {
  for_each = { for idx, clus in var.cluster_names : clus => idx }

  name                            = "${azurerm_resource_group.rg.name}-${each.key}-vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1ls"
  admin_username                  = "userone"
  admin_password                  = "User1pass"
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.vmnics[each.key].id
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

resource "azurerm_network_interface_security_group_association" "secgrp-nicassocs" {
  for_each = { for idx, clus in var.cluster_names : clus => idx }

  network_interface_id      = azurerm_network_interface.vmnics[each.key].id
  network_security_group_id = azurerm_network_security_group.secgrp.id
}

# Outputs

data "azurerm_public_ip" "ext-ip" {
  name                = azurerm_public_ip.pubip.name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_public_ip.pubip
  ]
}

output "pubip" {
  value = data.azurerm_public_ip.ext-ip.ip_address
}
