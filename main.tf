terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "4.59.0"
        }
    }
}

provider "azurerm" {
    features {}
        subscription_id = " "
    }


resource "azurerm_resource_group" "rg" {
    name = "demorg"
    location = "japanwest"
}


resource "azurerm_virtual_network" "vnet" {
    name = "demovnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "pip" {
    name = "demoip"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
}

resource "azurerm_subnet" "snet" {
    name = "demosubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
    name = "demonic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.snet.id
        public_ip_address_id = azurerm_public_ip.pip.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    name = "demovm"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic.id]

    size = "Standard_D2s_v5"
    admin_username = "patilabhi"
    admin_password = "Abhishek@2026"
    disable_password_authentication = false

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts"
        version = "latest"
    }
}
