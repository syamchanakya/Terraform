variable "location" {
  description = "The location where resources will be created"
  default     = "centralus"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = "map"

  default = {
    environment = "dev_syam"
  }
}
variable "resource_group" {
  description = "The name of the resource group in which the resources will be created"
  default     = "scalesyam"
}
variable "prefix" {
  description = "The prefix used for all resources in this example"
  type        = "string"
  default     = "rg"
}
variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 22
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Default password for admin account"
  default     = "Redhat@1234"
}
variable "size" {
  description = "Size of the VM"
  default     = "Standard_B1s"
}
variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "OpenLogic"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "CentOS"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "7.5"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}
variable "servercount" {
  description = "version of the image to apply (az vm image list)"
  default     = "2"
}
variable "hostname" {
  description = "Virtual Machine name referenced also in storage-related names."
  default     = "vmname"
}
variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.2.0/24"
}


variable "lb_natpool_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 22
}
variable "lb_rule_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}