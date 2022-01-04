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
  features {}
  subscription_id = "a712daa0-b387-4870-a11d-bb6cc1f310ab"
  tenant_id       = "664b5474-8c10-4757-ad67-77cb7f24f9fb"
}

locals {
  location            = "West Europe"
  rg_name             = "rg-terraform-vm"
  storageaccount_name = "stterraformvm04012022"
  vnet_name           = "vnet-terraform-vm"
  vnic_name           = "vnic-terraform-vm"
  snet_name           = "snet-terraform-vm-10"

}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_storage_account" "stg" {
  name                     = local.storageaccount_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = {
    environment = "development"
    type        = "Storage"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = ["172.16.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    environment = "development"
    type        = "Network"
  }
}

resource "azurerm_subnet" "snet" {
  name                 = local.snet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.10.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-terraform-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "development"
    type        = "Network"
  }
}

resource "azurerm_network_interface" "vnic" {
  name                = local.vnic_name
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.10.10"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  tags = {
    environment = "development"
    type        = "Network"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-terraform-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.vnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    name                 = "osDisk"
    disk_size_gb         = "512"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
