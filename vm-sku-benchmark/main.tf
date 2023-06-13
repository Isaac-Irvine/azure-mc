terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.60.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

locals {
  location    = "australiaeast"
  name_suffix = "vm-benchmark-1"
}

resource "azurerm_resource_group" "group" {
  name     = "rg-${local.name_suffix}"
  location = local.location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.group.name
}

resource "azurerm_subnet" "vm" {
  name                 = "vm"
  resource_group_name  = azurerm_resource_group.group.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/16"]
}


resource "azurerm_public_ip" "ip" {
  name                = "pip-${local.name_suffix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.group.name

  allocation_method = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${local.name_suffix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.group.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}


resource "azurerm_virtual_machine" "main" {
  name                  = "vm-${local.name_suffix}"
  location              = local.location
  resource_group_name   = azurerm_resource_group.group.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_D96as_v5"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.ip.ip_address
    user     = "testadmin"
    password = "Password1234!"
  }

  provisioner "remote-exec" {
    script = "docker install.sh"
  }

  provisioner "remote-exec" {
    script = "benchmark.sh"
  }

  provisioner "remote-exec" {
    inline = [ "shutdown --poweroff 0" ]
  }
}
