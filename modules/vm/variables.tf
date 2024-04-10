variable "resource_group_name" {
  type        = string
  description = "Resource group name"

  validation {
    condition = can(regex("^rg-",var.resource_group_name))
    error_message = "RG NAME IS NOT VALID. It should start with rg-."
  }
}

variable "resource_group_location" {
  type        = string
  description = "Location of the resource group."

  validation {
    condition = contains(["centralus","westeurope","northeurope"],var.resource_group_location)
    error_message = "Location is not valid."
  }
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet"
}

variable "network_interface_name" {
  type        = string
  description = "Name of the network interface"
}

variable "ip_configuration_name" {
  type        = string
  description = "Name of the IP configuration"
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"

  validation {
    condition = can(regex("^ONEAZRAP|^ABCAZRAP|^blue|^green",var.vm_name))
    error_message = "VM Name should start with ONE or ABC or blue or green."
  }

  validation {
    condition = length(var.vm_name) <= 15
    error_message = "Length of VM Name should be less than 15"
  }
}

variable "vm_size" {
  type        = string
  description = "The size of the virtual machine."
}

variable "storage_image_reference_publisher" {
  type        = string
  description = "The publisher of the image used to create the virtual machine."
}

variable "storage_image_reference_offer" {
  type        = string
  description = "Specifies the offer of the platform image or marketplace image used to create the virtual machine."
}

variable "storage_image_reference_sku" {
  type        = string
  description = "Specifies the SKU of the platform image or marketplace image used to create the virtual machine."
}

variable "storage_image_reference_version" {
  type        = string
  description = "Specifies the version of the platform image or marketplace image used to create the virtual machine."
}

variable "storage_os_disk_name" {
  type        = string
  description = "The name of the OS disk."
}

variable "storage_os_disk_caching" {
  type        = string
  description = "Specifies the caching requirements for the OS disk."
}

variable "storage_os_disk_create_option" {
  type        = string
  description = "Specifies how the virtual machine should be created."
}

variable "storage_os_disk_managed_disk_type" {
  type        = string
  description = "Specifies the storage account type for the managed disk."
}

variable "os_profile_computer_name" {
  type        = string
  description = "Specifies the host OS name of the virtual machine."
}

variable "admin_password" {
  type        = string
  description = "Specifies the password of the administrator account."
}

variable "nsg_name" {
  type        = string
  description = "Name of the network security group"
}

variable "os_profile_admin_username" {
  type        = string
  description = "Specifies the name of the administrator account."
}

variable "vm_count" {
  
}