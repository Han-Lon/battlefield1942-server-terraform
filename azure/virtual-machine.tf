resource "random_string" "initial-password" {
  length = 8
}

# TODO add a flag to determine if only local IP is used (won't work with Terraform Cloud)
data "http" "my-ip" {
  url = "https://ipv4.rawrify.com/ip"
}

resource "azurerm_resource_group" "bf1942-server-rg" {
  location = "Central US"  # Swap this out for another region closer to you if you want -> https://azure.microsoft.com/en-us/global-infrastructure/geographies/#overview
  name     = "battlefield1942"
}

resource "azurerm_linux_virtual_machine" "bf1942-server" {
  name                  = "battlefield1942-server"

  location              = azurerm_resource_group.bf1942-server-rg.location
  resource_group_name = azurerm_resource_group.bf1942-server-rg.name

  network_interface_ids = [
    azurerm_network_interface.bf1942-network-interface.id
  ]

  priority = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price = "0.03"  # TODO find a way to dynamically determine this

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

output "instance-admin-password" {
  value = "You can SSH into the host at IP ${azurerm_linux_virtual_machine.bf1942-server.public_ip_address} with username battlefieldroot and password ${random_string.initial-password.result}"
}