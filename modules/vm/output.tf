output "vm_id" {
    value = azurerm_virtual_machine.my_vm[*].id
}

output "network_interface_id" {
  value = azurerm_network_interface.my_nic[*].id
}

output "ip_configuration_name" {
  value = var.ip_configuration_name
}

output "private_ip_address" {
  value = azurerm_network_interface.my_nic[*].private_ip_address
}