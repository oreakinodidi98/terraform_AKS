#resource group in azure
resource "azurerm_resource_group" "aksrg" {
  name     = var.rg_names
  location = var.location
  tags     = var.tags
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
# resource "azurerm_private_endpoint" "privateendpoint" {
#   name                = "${var.naming_prefix}privateendpoint"
#   location            = azurerm_resource_group.aksrg.location
#   resource_group_name = azurerm_resource_group.aksrg.name
#   subnet_id           = azurerm_subnet.subnet.id
#   private_service_connection {
#     name                           = "${var.naming_prefix}privateserviceconnection"
#     private_connection_resource_id = azurerm_kubernetes_cluster.akscluster.id
#     subresource_names              = ["kube-apiserver"]
#     is_manual_connection           = false
#   }
# }
# user assigned identity in azure
