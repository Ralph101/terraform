terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.90.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
    
  }
  subscription_id = "a712daa0-b387-4870-a11d-bb6cc1f310ab"
  tenant_id = "664b5474-8c10-4757-ad67-77cb7f24f9fb"
}

resource "azurerm_resource_group" "rg-storage" {
  name     = "rg-terraform-stroageaccount"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "stralphterraform"
  resource_group_name      = azurerm_resource_group.rg-storage.name
  location                 = azurerm_resource_group.rg-storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "development"
  }
}
