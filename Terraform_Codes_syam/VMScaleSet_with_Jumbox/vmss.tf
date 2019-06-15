resource "azurerm_resource_group" "vmss" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vmss" {
  name                = "${var.resource_group}vnet"
  address_space       = "${var.address_space}"   #["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"
}

resource "azurerm_subnet" "vmss" {
  name                 = "${var.resource_group}subnet"
  resource_group_name  = "${azurerm_resource_group.vmss.name}"
  virtual_network_name = "${azurerm_virtual_network.vmss.name}"
  address_prefix       = "${var.subnet_prefix}"    #"10.0.2.0/24"
}

resource "azurerm_public_ip" "vmss" {
  name                = "${var.resource_group}publicip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  allocation_method   = "Static"
#  domain_name_label  = "${azurerm_resource_group.vmss.name}"
   tags               = "${var.tags}"
}

resource "azurerm_lb" "vmss" {
  name                = "${var.resource_group}-load_balancer"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.vmss.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id     = "${azurerm_lb.vmss.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = "${azurerm_resource_group.vmss.name}"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.vmss.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 5000
  frontend_port_end              = 5050
  backend_port                   = "${var.lb_natpool_port}"
  frontend_ip_configuration_name = "PublicIPAddress"
}
resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id                = "${azurerm_lb.vmss.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = "${var.lb_rule_port}"
  backend_port                   = "${var.lb_rule_port}"
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.vmss.id}"
  depends_on                     = ["azurerm_lb_probe.vmss"]
}
resource "azurerm_lb_probe" "vmss" {
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  loadbalancer_id     = "${azurerm_lb.vmss.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = "${var.servercount}"
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = "webvmssscaleset"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vmss.name}"

  # automatic rolling upgrade
 # automatic_os_upgrade = true
  upgrade_policy_mode  = "Manual"

 #   rolling_upgrade_policy {
 #   max_batch_instance_percent              = 20
 #   max_unhealthy_instance_percent          = 20
 #   max_unhealthy_upgraded_instance_percent = 5
 #   pause_time_between_batches              = "PT0S"
 # }

 #   health_probe_id = "${azurerm_lb_probe.vmss.id}"

  sku {
    name     = "${var.size}"
    tier     = "Standard"
    capacity = "${var.servercount}"
  }

  storage_profile_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "${format("${var.resource_group}vm%03d", count.index + 1)}"
    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_password}"
    custom_data    = "${file("web.conf")}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

  }

  network_profile {
    name    = "scalevmnetwork"
    primary = true

    ip_configuration {
      name                                   = "vmssIPConfiguration"
      primary                                = true
      subnet_id                              = "${azurerm_subnet.vmss.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool.*.id, count.index)}"]
    }
  }

  tags        = "${var.tags}"
}