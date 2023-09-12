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
