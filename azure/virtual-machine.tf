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

resource "azurerm_virtual_network" "bf1942-network" {
  address_space       = ["192.168.244.0/28"]
  location            = azurerm_resource_group.bf1942-server-rg.location
  name                = "bf1942-server-network"
  resource_group_name = azurerm_resource_group.bf1942-server-rg.name
}

resource "azurerm_subnet" "bf1942-subnet" {
  name                 = "bf1942-server-subnet"
  resource_group_name  = azurerm_resource_group.bf1942-server-rg.name
  virtual_network_name = azurerm_virtual_network.bf1942-network.name
  address_prefixes = ["192.168.244.0/28"]
}

resource "azurerm_public_ip" "bf1942-public-ip" {
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.bf1942-server-rg.location
  name                = "bf1942-server-public-ip"
  resource_group_name = azurerm_resource_group.bf1942-server-rg.name
}

resource "azurerm_network_interface" "bf1942-network-interface" {
  location            = azurerm_resource_group.bf1942-server-rg.location
  name                = "bf1942-server-network-interface"
  resource_group_name = azurerm_resource_group.bf1942-server-rg.name
  ip_configuration {
    name                          = "public-ip"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.bf1942-public-ip.id
    subnet_id = azurerm_subnet.bf1942-subnet.id
  }
}

resource "azurerm_network_security_group" "bf1942-security-group" {
  name                = "bf1942-server-security-group"
  location            = azurerm_resource_group.bf1942-server-rg.location
  resource_group_name = azurerm_resource_group.bf1942-server-rg.name

  security_rule {
    name      = "AllowInboundGamePorts"
    access    = "Allow"
    direction = "Inbound"
    priority  = 100
    protocol  = "*"
    source_port_range = "*"
    source_address_prefix = "${data.http.my-ip.body}/32"
    destination_port_range = "14567"
    destination_address_prefix = "*"
  }

  security_rule {
    name      = "AllowInboundGamePortsQuery"
    access    = "Allow"
    direction = "Inbound"
    priority  = 101
    protocol  = "*"
    source_port_range = "*"
    source_address_prefix = "${data.http.my-ip.body}/32"
    destination_port_range = "22000"
    destination_address_prefix = "*"
  }

  security_rule {
    name      = "AllowInboundSSH"
    access    = "Allow"
    direction = "Inbound"
    priority  = 102
    protocol  = "Tcp"
    source_port_range = "*"
    source_address_prefix = "${data.http.my-ip.body}/32"
    destination_port_range = "22"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "bf1942-sg-association" {
  network_interface_id      = azurerm_network_interface.bf1942-network-interface.id
  network_security_group_id = azurerm_network_security_group.bf1942-security-group.id
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