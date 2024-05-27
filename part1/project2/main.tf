resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.rg_name}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_cidr
}

resource "azurerm_subnet" "main" {
  for_each = var.subnets 
  name                 = each.key
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes = toset(each.value)
}

resource "azurerm_public_ip" "main" {
  for_each = {for key, value in var.vms: key => value if value.public_ip}
  name                = "${each.key}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_interface" "main" {
  for_each = var.vms

  name                = "${each.key}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main[each.value.subnet].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = each.value.public_ip ? azurerm_public_ip.main[each.key].id : null
  }
}



resource "azurerm_linux_virtual_machine" "main" {
  for_each = var.vms
  
  name                = each.key
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  zone                = "2"
  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
  ]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("../.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  custom_data         = data.cloudinit_config.main.rendered
}

data "cloudinit_config" "main" {
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloud_config.yaml")
  }
}

