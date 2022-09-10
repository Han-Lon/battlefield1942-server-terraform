resource "random_string" "initial-password" {
  length = 8
}

resource "azurerm_resource_group" "bf1942-server-rg" {
  location = var.azure-region
  name     = "battlefield1942"
}

# Use a spot virtual machine if the use-spot-instance variable is set to true. These are cheaper than regular, but can be terminated by Azure
resource "azurerm_linux_virtual_machine" "bf1942-spot-server" {
  count = var.use-spot-instance ? 1 : 0
  name                  = "battlefield1942-server"

  location              = azurerm_resource_group.bf1942-server-rg.location
  resource_group_name = azurerm_resource_group.bf1942-server-rg.name

  network_interface_ids = [
    azurerm_network_interface.bf1942-network-interface.id
  ]

  priority = "Spot"
  eviction_policy = "Deallocate"

  admin_username = "battlefieldroot"
  admin_password = random_string.initial-password.result
  disable_password_authentication = false # TODO set this to false and use an SSH key-- more secure

  custom_data = base64encode(templatefile("../server-bootstrap.sh", {
    PASSWD = random_string.initial-password.result
  }))

  size                  = "Standard_D2s_v3"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

# Launch a regular virtual machine if use-spot-instance is set to false
resource "azurerm_linux_virtual_machine" "bf1942-server" {
  count = !var.use-spot-instance ? 0 : 1
  name                  = "battlefield1942-server"

  location              = azurerm_resource_group.bf1942-server-rg.location
  resource_group_name = azurerm_resource_group.bf1942-server-rg.name

  network_interface_ids = [
    azurerm_network_interface.bf1942-network-interface.id
  ]

  admin_username = "battlefieldroot"
  admin_password = random_string.initial-password.result
  disable_password_authentication = false

  custom_data = base64encode(templatefile("../server-bootstrap.sh", {
    PASSWD = random_string.initial-password.result
  }))

  size                  = "Standard_D2s_v3"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

# Output how to connect to the server based on which server type was deployed
output "spot-instance-admin-password" {
  value = var.use-spot-instance ? "You can SSH into the host at IP ${azurerm_linux_virtual_machine.bf1942-spot-server[0].public_ip_address} with username battlefieldroot and password ${random_string.initial-password.result}" : "You can SSH into the host at IP ${azurerm_linux_virtual_machine.bf1942-server[0].public_ip_address} with username battlefieldroot and password ${random_string.initial-password.result}"
}