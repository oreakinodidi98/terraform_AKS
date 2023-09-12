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
  records             = ["10.0.180.17"]
}