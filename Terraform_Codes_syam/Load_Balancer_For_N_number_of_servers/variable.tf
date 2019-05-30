variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
}
variable "hostname" {
  description = "Virtual Machine name referenced also in storage-related names."
}
variable "servercount" {
  description =     "The number of Server virtual machine resource need to be created.  eg: 1 ,2 ,3...."
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created. eg : southcentralus, eastus, westus"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine. eg Standard_B1ls ,Standard_DS1_v2 "
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "WindowsServer"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "2012-R2-Datacenter"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "Virtual Machine Administrator user name"
}

variable "admin_password" {
  description = "administrator password which must be complex password"
}