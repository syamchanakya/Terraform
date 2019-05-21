variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created.  eg: Project name, Resource name"
}
variable "location" {
  description = "The name of the location where resources will be created.   eg: eastus, northcentralus"     
}
variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}