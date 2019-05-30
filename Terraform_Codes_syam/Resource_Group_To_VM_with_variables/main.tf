#####Resource Group creation#######################################
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}
###########Virtual Network Creation################################
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.resource_group_name}-vnet"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    address_space       = ["10.0.0.0/16"]
      tags     = "${var.tags}"
}
########################### SUBNET ################################
resource "azurerm_subnet" "subnet" {
    name                 = "${var.resource_group_name}-subnet"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix       = "10.0.2.0/24"
}
#################### Assign public IP #############################
resource "azurerm_public_ip" "publicip" {
    name                         = "${var.resource_group_name}-publicip"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method            = "Dynamic"
    tags     = "${var.tags}"
}
################### Creating security group #######################
resource "azurerm_network_security_group" "nsg" {
    name                = "${var.resource_group_name}-nsg"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "WEB_SERVICE"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}
##################Creating a Network Interface card ###################
resource "azurerm_network_interface" "nic" {
    name                = "${var.resource_group_name}-nic"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"


    ip_configuration {
        name                          = "${var.resource_group_name}-ipconfig"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
    }
    tags     = "${var.tags}"
}
#######################Boot diagnostic Disk ##########################
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.rg.name}"
    }
    
    byte_length = 8
}
######################Storage#########################################
resource "azurerm_storage_account" "storageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location            = "${var.location}"
    account_replication_type = "LRS"
    account_tier = "Standard"
    tags     = "${var.tags}"
}
######################### Virtual Machine ###########################
resource "azurerm_virtual_machine" "vm" {
    name                  = "${var.resource_group_name}-vm"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${azurerm_network_interface.nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "${var.resource_group_name}-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "vm1"
        admin_username = "azureuser"
        admin_password = "Password@123"
    }
delete_os_disk_on_termination = true
    os_profile_linux_config {
        disable_password_authentication = false
 #       ssh_keys {
 #           path     = "/home/azureuser/.ssh/authorized_keys"
 #           key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
 #       }
    }
       
    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.storageaccount.primary_blob_endpoint}"
    }

    tags     = "${var.tags}"
}
