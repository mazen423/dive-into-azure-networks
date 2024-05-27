resource "azurerm_virtual_network_peering" "main" {
  count                     = var.remote_virtual_network_id != "" ? 1 : 0  
  name                      = "peer-project2-to-project1"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = var.remote_virtual_network_id
}
