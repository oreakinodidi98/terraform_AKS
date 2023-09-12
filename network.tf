# virtual network in azure
resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "${var.naming_prefix}virtualnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
}
# subnet in virtual network
resource "azurerm_subnet" "service" {
  name                 = "${var.naming_prefix}subnet_service"
  resource_group_name  = azurerm_resource_group.aksrg.name
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes     = ["10.0.1.0/24"]

  #enforce_private_link_endpoint_network_policies = false
  private_endpoint_network_policies_enabled = false
}
resource "azurerm_subnet" "endpoint" {
  name                 = "${var.naming_prefix}subnet_endpoint"
  resource_group_name  = azurerm_resource_group.aksrg.name
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}
# network interface in azure
resource "azurerm_network_interface" "networkinterface" {
  name                = "${var.naming_prefix}networkinterface"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.endpoint.id
    private_ip_address_allocation = "Dynamic"
  }
}
# public ip in azure
resource "azurerm_public_ip" "publicip" {
  name                = "${var.naming_prefix}publicip"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  #   ip_version          = "IPv4"
  tags = var.tags
}
# load balancer in azure
resource "azurerm_lb" "azurelb" {
  name                = "${var.naming_prefix}-lb"
  sku                 = "Standard"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.publicip.name
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}
# private link service in azure
resource "azurerm_private_link_service" "privatelinkservice" {
  name                = "${var.naming_prefix}privatelinkservice"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name

  nat_ip_configuration {
    name      = azurerm_public_ip.publicip.name
    primary   = true
    subnet_id = azurerm_subnet.service.id
  }
  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.azurelb.frontend_ip_configuration[0].id]
  tags                                        = var.tags
}
# private endpoint in azure
resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "${var.naming_prefix}privateendpoint"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  subnet_id           = azurerm_subnet.endpoint.id
  private_service_connection {
    name                           = "${var.naming_prefix}privateserviceconnection"
    private_connection_resource_id = azurerm_private_link_service.privatelinkservice.id
    #subresource_names              = ["privatelinkservice"]
    is_manual_connection = false
  }
  tags = var.tags
}
# network security group in azure
resource "azurerm_network_security_group" "networksecuritygroup" {
  name                = "${var.naming_prefix}networksecuritygroup"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}