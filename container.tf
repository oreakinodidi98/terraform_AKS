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