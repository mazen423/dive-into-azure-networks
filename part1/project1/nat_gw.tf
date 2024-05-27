
resource "azurerm_public_ip" "nat_gateway" {
  name                = "${var.rg_name}-nat-gw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]

}

resource "azurerm_nat_gateway" "main" {
  name                = "${var.rg_name}-nat-gw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard"
  zones               = ["2"]
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat_gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  for_each       = toset(keys(var.subnets))
  subnet_id      = azurerm_subnet.main[each.value].id
  nat_gateway_id = azurerm_nat_gateway.main.id
}
