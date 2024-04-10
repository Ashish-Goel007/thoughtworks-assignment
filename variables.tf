locals {
  location           = "centralus"
  vnet_address_space = "10.0.0.0/16"

}

variable "rg_name" {
  default = "rg-test"
}

variable "vnet_name" {
  default = "myvnet"
}

variable "public_ip_blue_name" {
  default = "mybluepublicip"
}

variable "public_ip_green_name" {
  default = "mygreenpublicip"
}

variable "blue_load_balancer_frontend_ip_configuration_name" {
  default = "mybluelbpublicip"
}

variable "green_load_balancer_frontend_ip_configuration_name" {
  default = "mygreenlbpublicip"
}

variable "load_balancer_name" {
  default = "mylb"
}

variable "ip_configuration_name" {
  default = "myip"

}

variable "network_interface_name" {
  default = "mynic"
}

variable "storage_os_disk_name" {
  default = "myosdisk"
}

variable "nsg_name" {
  default = "mynsg"
}

variable "admin_password" {
  type = string
}