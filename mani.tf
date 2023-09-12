#resource group in azure
resource "azurerm_resource_group" "aksrg" {
  name     = var.rg_names
  location = var.location
  tags     = var.tags
}
#storage account in azure
resource "azurerm_storage_account" "storageaccount" {
  name                     = "${var.naming_prefix}storage"
  resource_group_name      = azurerm_resource_group.aksrg.name
  location                 = azurerm_resource_group.aksrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}
#container in storage account
resource "azurerm_storage_container" "storagecontainer" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.storageaccount.name
  container_access_type = "private"
}
#container registry in azure
resource "azurerm_container_registry" "containerregistry" {
  name                = "${var.naming_prefix}containerregistry"
  resource_group_name = azurerm_resource_group.aksrg.name
  location            = azurerm_resource_group.aksrg.location
  sku                 = "Premium"
  admin_enabled       = true
  #georeplication_locations = ["UK South"]
  tags = var.tags
}
# container instance in azure
resource "azurerm_container_group" "containerinstance" {
  name                = "${var.naming_prefix}containerinstance"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  ip_address_type     = "Public"
  dns_name_label      = "${var.naming_prefix}containerinstance"
  os_type             = "Linux"
  restart_policy      = "OnFailure"
  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  container {
    name   = "sidecar"
    image  = "mcr.microsoft.com/azuredocs/aci-tutorial-sidecar"
    cpu    = "0.5"
    memory = "1.5"
  }
  tags = var.tags
}
# virtual network in azure
resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "${var.naming_prefix}virtualnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
}
# subnet in virtual network
resource "azurerm_subnet" "subnet" {
  name                 = "${var.naming_prefix}subnet"
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
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# public ip in azure
resource "azurerm_public_ip" "publicip" {
  name                = "${var.naming_prefix}publicip"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  allocation_method   = "Dynamic"
  ip_version          = "IPv4"
  tags                = var.tags
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
# kubernetes cluster in azure
resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "${var.naming_prefix}akscluster"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  dns_prefix          = "${var.naming_prefix}akscluster"
  # linux_profile {
  #   admin_username = "azureuser"
  #   ssh_key {
  #     key_data = file("~/.ssh/id_rsa.pub")
  #   }
  # }
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

# private dns zone in azure
resource "azurerm_private_dns_zone" "privatednszone" {
  name                = "${var.naming_prefix}privatednszone.demo.dev"
  resource_group_name = azurerm_resource_group.aksrg.name
  tags                = var.tags
}
# private dns record in azure
resource "azurerm_private_dns_a_record" "privatednsrecord" {
  name                = "${var.naming_prefix}privatednsrecord"
  zone_name           = azurerm_private_dns_zone.privatednszone.name
  resource_group_name = azurerm_resource_group.aksrg.name
  ttl                 = 300
  records             = [azurerm_kubernetes_cluster.akscluster.fqdn]
}
# # private dns record in azure
# resource "azurerm_private_dns_a_record" "privatednsrecord" {
#   name                = "${var.naming_prefix}privatednsrecord"
#   zone_name           = azurerm_private_dns_zone.privatednszone.name
#   resource_group_name = azurerm_resource_group.aksrg.name
#   ttl                 = 300
#   #target_resource_id  = azurerm_kubernetes_cluster.akscluster.id
#   records             = [azurerm_kubernetes_cluster.akscluster.private_fqdn]
# }
# private endpoint in azure
resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "${var.naming_prefix}privateendpoint"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  subnet_id           = azurerm_subnet.subnet.id
  private_service_connection {
    name                           = "${var.naming_prefix}privateserviceconnection"
    private_connection_resource_id = azurerm_kubernetes_cluster.akscluster.id
    subresource_names              = ["kube-apiserver"]
    is_manual_connection = false
  }
}
# user assigned identity in azure
resource "azurerm_user_assigned_identity" "userassignedidentity" {
  name                = "${var.naming_prefix}userassignedidentity"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
}
# role assignment in azure
resource "azurerm_role_assignment" "aksrole" {
  scope                = azurerm_container_registry.containerregistry.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_user_assigned_identity.userassignedidentity.principal_id
}
