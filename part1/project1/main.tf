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

resource "azurerm_network_security_group" "main" {
  for_each = toset(keys(var.nsgs))

  name = "${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "preset_rules" {
  for_each = merge([for nsg_name,nsg_value in var.nsgs : {
    for rule_name, rule_attrs in nsg_value.rules : 
    join("-",[nsg_name,rule_name]) => merge(rule_attrs,
    {nsg_name = nsg_name , rule_name = rule_name})
  }]...)

  name                          = each.value.rule_name
  direction                     = each.value.direction
  priority                      = each.value.priority
  access                        = each.value.access
  protocol                      = each.value.protocol
  source_port_range             = each.value.source.port_range
  source_address_prefix         = each.value.source.ip_range
  destination_port_range        = each.value.destination.port_range
  destination_address_prefix    = each.value.destination.ip_range
  resource_group_name           = azurerm_resource_group.main.name
  network_security_group_name   = azurerm_network_security_group.main[each.value.nsg_name].name
}

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each                  = var.nsgs
  subnet_id                 = azurerm_subnet.main[each.value.subnet].id
  network_security_group_id = azurerm_network_security_group.main[each.key].id
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

