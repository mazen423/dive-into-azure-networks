resource "azurerm_public_ip" "bastion" {

  name =              "${var.rg_name}-bastion-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]
}

resource "azurerm_bastion_host" "main" {

  name                = "${var.rg_name}-bastion"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                 = "main"
    subnet_id            = azurerm_subnet.main["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
