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
    source_address_prefix = "*"
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
    source_address_prefix = "*"
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
    source_address_prefix = var.allowed-ssh-ip == "" ? "*" : "${data.http.my-ip.body}/32"
    destination_port_range = "22"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "bf1942-sg-association" {
  network_interface_id      = azurerm_network_interface.bf1942-network-interface.id
  network_security_group_id = azurerm_network_security_group.bf1942-security-group.id
}