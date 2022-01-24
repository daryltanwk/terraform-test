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

resource "azurerm_resource_group" "test" {
  location = "Southeast Asia"
  name     = "test-dt"
}

# Virtual Machines

resource "azurerm_virtual_machine" "db" {

}

resource "azurerm_virtual_machine" "app" {

}

resource "azurerm_virtual_machine" "web" {

}
