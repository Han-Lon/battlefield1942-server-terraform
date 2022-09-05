resource "azurerm_linux_virtual_machine" "bf1942-server" {
  admin_username        = ""
  location              = ""
  name                  = "battlefield1942-server"
  network_interface_ids = []
  resource_group_name   = ""
  size                  = ""
  os_disk {
    caching              = ""
    storage_account_type = ""
  }
}