# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = local.location
}

# Create the virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [local.vnet_address_space]
  depends_on          = [azurerm_resource_group.rg]
}

# Define the three subnets
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_resource_group.rg, azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_resource_group.rg, azurerm_virtual_network.vnet]
}


resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
  depends_on           = [azurerm_resource_group.rg, azurerm_virtual_network.vnet]
}

#Create blue VM
module "blue_vm" {
  source                            = "./modules/vm"
  vm_count                          = 2
  ip_configuration_name             = "blue-${var.ip_configuration_name}"
  network_interface_name            = "blue-${var.network_interface_name}"
  admin_password                    = var.admin_password
  os_profile_admin_username         = "testadmin"
  os_profile_computer_name          = "bluevm"
  resource_group_location           = local.location
  resource_group_name               = azurerm_resource_group.rg.name
  storage_image_reference_offer     = "0001-com-ubuntu-server-jammy"
  storage_image_reference_publisher = "Canonical"
  storage_image_reference_sku       = "22_04-lts"
  storage_image_reference_version   = "latest"
  storage_os_disk_caching           = "ReadWrite"
  storage_os_disk_create_option     = "FromImage"
  storage_os_disk_managed_disk_type = "Standard_LRS"
  storage_os_disk_name              = "blue-${var.storage_os_disk_name}"
  subnet_name                       = azurerm_subnet.subnet1.name
  vm_name                           = "blue-vm"
  vm_size                           = "Standard_DS1_v2"
  vnet_name                         = azurerm_virtual_network.vnet.name
  subnet_id                         = azurerm_subnet.subnet1.id
  nsg_name                          = "blue-${var.nsg_name}"

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_subnet.subnet1,
    azurerm_virtual_network.vnet
  ]
}



#Create green VM
module "green_vm" {
  source                            = "./modules/vm"
  vm_count                          = 2
  ip_configuration_name             = "green-${var.ip_configuration_name}"
  network_interface_name            = "green-${var.network_interface_name}"
  admin_password                    = var.admin_password
  os_profile_admin_username         = "testadmin"
  os_profile_computer_name          = "greenvm"
  resource_group_location           = local.location
  resource_group_name               = azurerm_resource_group.rg.name
  storage_image_reference_offer     = "0001-com-ubuntu-server-jammy"
  storage_image_reference_publisher = "Canonical"
  storage_image_reference_sku       = "22_04-lts"
  storage_image_reference_version   = "latest"
  storage_os_disk_caching           = "ReadWrite"
  storage_os_disk_create_option     = "FromImage"
  storage_os_disk_managed_disk_type = "Standard_LRS"
  storage_os_disk_name              = "green-${var.storage_os_disk_name}"
  subnet_name                       = azurerm_subnet.subnet2.name
  vm_name                           = "green-vm"
  vm_size                           = "Standard_DS1_v2"
  vnet_name                         = azurerm_virtual_network.vnet.name
  subnet_id                         = azurerm_subnet.subnet2.id
  nsg_name                          = "green-${var.nsg_name}"

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_subnet.subnet1,
    azurerm_virtual_network.vnet
  ]
}


# Create the Public IP address for the Blue Load Balancer
resource "azurerm_public_ip" "blue_public_ip" {
  name                    = var.public_ip_blue_name
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Static"
  location                = local.location
  sku                     = "Standard"
  depends_on              = [azurerm_resource_group.rg]
  ddos_protection_mode    = "Enabled"
  ddos_protection_plan_id = azurerm_network_ddos_protection_plan.my-ddos-plan.id
}



resource "azurerm_network_ddos_protection_plan" "my-ddos-plan" {
  name                = "my-ddos-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
}


# Create the Public IP address for the Greem Load Balancer
resource "azurerm_public_ip" "green_public_ip" {
  name                = var.public_ip_green_name
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  location            = local.location
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.rg]
}

# Create Load balancer
resource "azurerm_lb" "public_lb" {
  name                = var.load_balancer_name
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.blue_load_balancer_frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.blue_public_ip.id
  }

  frontend_ip_configuration {
    name                 = var.green_load_balancer_frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.green_public_ip.id
  }

  depends_on = [
    azurerm_public_ip.blue_public_ip,
    azurerm_public_ip.green_public_ip
  ]
}


# Create Backend Pools
resource "azurerm_lb_backend_address_pool" "blue_pool" {
  loadbalancer_id = azurerm_lb.public_lb.id
  name            = "blue-pool"
}

resource "azurerm_lb_backend_address_pool" "green_pool" {
  loadbalancer_id = azurerm_lb.public_lb.id
  name            = "green-pool"
}

# Adding VM into the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "blue_lb_association" {
  count                   = length(module.blue_vm.network_interface_id)
  network_interface_id    = module.blue_vm.network_interface_id[count.index]
  ip_configuration_name   = module.blue_vm.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.blue_pool.id

  depends_on = [
    module.blue_vm,
    azurerm_lb.public_lb
  ]
}

resource "azurerm_network_interface_backend_address_pool_association" "green_lb_association" {
  count                   = length(module.green_vm.network_interface_id)
  network_interface_id    = module.green_vm.network_interface_id[count.index]
  ip_configuration_name   = module.green_vm.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.green_pool.id

  depends_on = [
    module.green_vm,
    azurerm_lb.public_lb
  ]
}

# Load Balancer Rules
resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = azurerm_lb.public_lb.id
  name            = "http-probe"
  port            = 80
}

resource "azurerm_lb_rule" "http_rule_blue" {
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "http-rule-blue"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.blue_load_balancer_frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.blue_pool.id]
  probe_id                       = azurerm_lb_probe.http_probe.id

  depends_on = [
    azurerm_lb_probe.http_probe,
    azurerm_lb.public_lb
  ]
}

resource "azurerm_lb_rule" "http_rule_green" {
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "http-rule-green"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.green_load_balancer_frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.green_pool.id]
  probe_id                       = azurerm_lb_probe.http_probe.id

  depends_on = [
    azurerm_lb_probe.http_probe,
    azurerm_lb.public_lb
  ]
}


