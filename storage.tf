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
