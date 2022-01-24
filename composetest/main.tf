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

resource "azurerm_resource_group" "test" {
  location = "Southeast Asia"
  name     = "test-dt"
}

resource "azurerm_app_service_plan" "svcplan" {
  name                = "${azurerm_resource_group.test.name}-appsvcplan"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  kind     = "Linux"
  reserved = true

  sku {
    size = "F1"
    tier = "Free"
  }
}

resource "azurerm_app_service" "app" {
  app_service_plan_id = azurerm_app_service_plan.svcplan.id
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  name                = "${azurerm_resource_group.test.name}-app"

}
