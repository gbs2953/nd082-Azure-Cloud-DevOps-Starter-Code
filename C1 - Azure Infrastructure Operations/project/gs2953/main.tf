terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.41.0"
    }
  }
}

provider "azurerm" {
  features {}
}

//resource "azurerm_resource_group" "udacityProject1" {
//  name     = "${var.prefix}-RG"
//  location = var.location
//  tags     = var.tags
//}

# we assume that this Custom Image already exists
data "azurerm_image" "packer-img" {
  name                = var.custom_image_name
  resource_group_name = "${var.prefix}-RG"
}

resource "azurerm_virtual_network" "udacityProject1" {
  name                = "${var.prefix}-vnet"
  resource_group_name = "${var.prefix}-RG"
  location            = var.location
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "udacityProject1" {
  name                 = "${var.prefix}-int-subnet"
  virtual_network_name = azurerm_virtual_network.udacityProject1.name
  resource_group_name = "${var.prefix}-RG"
  address_prefixes     = [var.subnet_address_space]
}

resource "azurerm_subnet_network_security_group_association" "udacityProject1" {
  subnet_id                 = azurerm_subnet.udacityProject1.id
  network_security_group_id = azurerm_network_security_group.udacityProject1.id
}

resource "azurerm_network_security_group" "udacityProject1" {
  name                = "${var.prefix}-nsg"
  resource_group_name = "${var.prefix}-RG"
  location            = var.location
  security_rule       = [
    {
      name                                       = "${var.prefix}-nsgrule1000"
      priority                                   = 1000
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "*"
      source_application_security_group_ids      = []
      source_address_prefixes                    = []
      source_address_prefix                      = var.subnet_address_space
      source_port_ranges                         = []
      source_port_range                          = "*"
      destination_address_prefixes               = []
      destination_address_prefix                 = "VirtualNetwork"
      destination_application_security_group_ids = []
      destination_port_ranges                    = []
      destination_port_range                     = "*"
      description                                = "Allow inbound traffic from subnet"
    },
    {
      name                                       = "${var.prefix}-nsgrule2000"
      priority                                   = 2000
      direction                                  = "Inbound"
      access                                     = "Deny"
      protocol                                   = "*"
      source_application_security_group_ids      = []
      source_port_ranges                         = []
      source_port_range                          = "*"
      source_address_prefixes                    = []
      source_address_prefix                      = "Internet"
      destination_address_prefixes               = []
      destination_address_prefix                 = "*"
      destination_application_security_group_ids = []
      destination_port_ranges                    = []
      destination_port_range                     = "*"
      description                                = "Deny inbound Internet traffic"
    }
  ]
  tags = var.tags
}

resource "azurerm_network_interface" "udacityProject1" {
  count                     = var.vms_in_availability_set
  name                      = "${var.prefix}-nic${count.index}"
  location                  = var.location
  resource_group_name       = "${var.prefix}-RG"

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.udacityProject1.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "udacityProject1" {
  count                     = var.vms_in_availability_set
  network_interface_id      = element(azurerm_network_interface.udacityProject1.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.udacityProject1.id
}

resource "azurerm_public_ip" "udacityProject1" {
  name                = "${var.prefix}-pip"
  resource_group_name = "${var.prefix}-RG"
  location            = var.location
  allocation_method   = "Static"

  tags                = var.tags
}

resource "azurerm_lb" "udacityProject1" {
  name                   = "${var.prefix}-lb"
  resource_group_name   = "${var.prefix}-RG"
  location              = var.location

  frontend_ip_configuration {
    name                 = "${var.prefix}-fe-ip-config"
    public_ip_address_id = azurerm_public_ip.udacityProject1.id
  }

  tags                   = var.tags
}

resource "azurerm_lb_backend_address_pool" "udacityProject1" {
  count               = var.vms_in_availability_set
  loadbalancer_id     = azurerm_lb.udacityProject1.id
  name                = "${var.prefix}-be-addr-pool${count.index}"
}

resource "azurerm_network_interface_backend_address_pool_association" "udacityProject1" {
  count                   = var.vms_in_availability_set
  backend_address_pool_id = azurerm_lb_backend_address_pool.udacityProject1[count.index].id
  ip_configuration_name   = azurerm_network_interface.udacityProject1[count.index].ip_configuration[0].name
  network_interface_id    = element(azurerm_network_interface.udacityProject1.*.id, count.index)
}

resource "azurerm_availability_set" "udacityProject1" {
  name                         = "${var.prefix}-avset"
  resource_group_name          = "${var.prefix}-RG"
  location                     = var.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  tags                         = var.tags
}

resource "azurerm_virtual_machine" "udacityProject1" {
  count                 = var.vms_in_availability_set
  name                  = "${var.prefix}-vm${count.index}"
  resource_group_name   = "${var.prefix}-RG"
  location              = var.location
  availability_set_id   = azurerm_availability_set.udacityProject1.id
  network_interface_ids = [
    azurerm_network_interface.udacityProject1[count.index].id,
  ]
  vm_size               = var.vm_sku

  storage_image_reference {
    id = data.azurerm_image.packer-img.id
  }

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "osdisk-${count.index}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm${count.index}"
    admin_username = "tfuser"
    admin_password = "P@ssW0RD7890"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags     = var.tags
}

resource "azurerm_managed_disk" "udacityProject1" {
  count                = var.vms_in_availability_set
  name                 = "${var.prefix}-managed-disk${count.index}"
  location             = var.location
  create_option        = "Empty"
  disk_size_gb         = 10
  resource_group_name  = "${var.prefix}-RG"
  storage_account_type = "Standard_LRS"

  tags     = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "udacityProject1" {
  count              = var.vms_in_availability_set
  virtual_machine_id = azurerm_virtual_machine.udacityProject1[count.index].id
  managed_disk_id    = azurerm_managed_disk.udacityProject1[count.index].id
  lun                = count.index
  caching            = "None"
}
