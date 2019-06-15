resource "random_string" "fqdn" {
  length  = 8
  special = false
  upper   = false
  number  = false
}

resource "azurerm_public_ip" "jumpboxs" {
 name                         = "jumpbox-public-ip"
 location                     = "${var.location}"
 resource_group_name          = "${azurerm_resource_group.vmss.name}"
 allocation_method = "Static"
 domain_name_label            = "${random_string.fqdn.result}-ssh"
 tags                         = "${var.tags}"
}

resource "azurerm_network_interface" "jumpbox" {
 name                = "jumpbox-nic"
 location            = "${var.location}"
 resource_group_name = "${azurerm_resource_group.vmss.name}"

 ip_configuration {
   name                          = "IPConfiguration"
   subnet_id                     = "${azurerm_subnet.vmss.id}"
   private_ip_address_allocation = "Dynamic"
   public_ip_address_id          = "${azurerm_public_ip.jumpboxs.id}"
 }

 tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "jumpbox" {
 name                  = "jumpbox"
 location              = "${var.location}"
 resource_group_name   = "${azurerm_resource_group.vmss.name}"
 network_interface_ids = ["${azurerm_network_interface.jumpbox.id}"]
 vm_size               = "Standard_B1s"

 storage_image_reference {
   publisher = "OpenLogic"
   offer     = "CentOS"
   sku       = "7.3"
   version   = "latest"
 }

 storage_os_disk {
   name              = "jumpbox-osdisk"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 os_profile {
   computer_name  = "jumpbox"
   admin_username = "${var.admin_user}"
   admin_password = "${var.admin_password}"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = "${var.tags}"
}