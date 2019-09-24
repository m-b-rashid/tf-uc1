

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}VN"
  location            = "${azurerm_resource_group.UC1.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.UC1.name}"
}
resource "random_string" "fqdn" {
 length  = 6
 special = false
 upper   = false
 number  = false
}
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}subnet1"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.UC1.name}"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_network_security_group" "belal-sg" {
  name                = "${var.prefix}-sg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.UC1.name}"

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_public_ip" "belal-pip" {
  name                = "${var.prefix}-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.UC1.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.hostname}"
}

resource "azurerm_network_interface" "belal-nic" {
  name                      = "${var.prefix}belal-nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.UC1.name}"
  network_security_group_id = "${azurerm_network_security_group.belal-sg.id}"

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.belal-pip.id}"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "test" {
  network_interface_id    = "${azurerm_network_interface.belal-nic.id}"
  ip_configuration_name   = "${var.prefix}ipconfig"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.backend_pool.id}"
}
resource "azurerm_public_ip" "belal-lb-pip" {
  name                = "${var.prefix}-lb-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.UC1.name}"
  allocation_method   = "Static"
  domain_name_label            = "${random_string.fqdn.result}"
}
resource "azurerm_lb" "belal-lb" {
  name                = "LoadBalancer"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.UC1.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.belal-lb-pip.id}"
  }
}
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.UC1.name}"
  loadbalancer_id     = "${azurerm_lb.belal-lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = "${azurerm_resource_group.UC1.name}"
  loadbalancer_id                = "${azurerm_lb.belal-lb.id}"
  name                           = "RDP-VM-${count.index}"
  protocol                       = "tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
  count                          = 2
}
resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.UC1.name}"
  loadbalancer_id                = "${azurerm_lb.belal-lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}
resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.UC1.name}"
  loadbalancer_id     = "${azurerm_lb.belal-lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}