# output of storage account id
output "storage_account_id" {
  value = azurerm_storage_account.storageaccount.id
}
# output of storage account name
output "storage_account_name" {
  value = azurerm_storage_account.storageaccount.name
}
# output of kubernetes cluster id
output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.akscluster.id
}
# output of kubernetes cluster name
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.akscluster.name
}
# output of container registry id
output "container_registry_id" {
  value = azurerm_container_registry.containerregistry.id
}
# output of cluster kube_config
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.akscluster.kube_config.0.client_certificate
  sensitive = true
}
# output of kube_config_raw
output "kube_config" {
  value     = azurerm_kubernetes_cluster.akscluster.kube_config_raw
  sensitive = true
}