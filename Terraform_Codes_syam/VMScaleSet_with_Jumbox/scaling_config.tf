#resource "azurerm_resource_group" "vmss" {
#  name     = "${var.resource_group_name}"
#  location = "${var.location}"
#  tags     = "${var.tags}"
#}

#resource "azurerm_virtual_machine_scale_set" "vmss" {
#   ...
#}

resource "azurerm_monitor_autoscale_setting" "vmss" {
  name                = "vmss-scaleset-setting"
  resource_group_name = "${azurerm_resource_group.vmss.name}"
  location            = "${var.location}"
  target_resource_id  = "${azurerm_virtual_machine_scale_set.vmss.id}"

  profile {
    name = "loadaveragethrashold"

    capacity {
      default = "${var.servercount}"
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.vmss.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 5
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.vmss.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 2
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["syam.sasipillai@hrblock.com"]
    }
  }
}