variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  default     = "cb5b077c-3ef5-4b2e-83e5-490cc5ca0e19"
}
variable "azure_tenant_id" {
  description = "The Azure tenant ID"
  type        = string
  default     = "16b3c013-d300-468d-ac64-7eda0820b6d3"
}
variable "azure_client_id" {
  description = "The Azure client ID"
  type        = string
  default     = "54eb7456-b767-487c-80ef-e79d0f13694c"
}
variable "location" {
  type        = string
  description = "value to be added as location"
  default     = "UK South"
}
variable "rg_names" {
  description = "value to be added as rg name"
  type        = string
  default     = "rg-aks-demo"
}
variable "tags" {
  description = "value to be added as tags, it is a map data type and default value is delete"
  type        = map(any)
  default = {
    resource = "Demo"
  }
}
variable "naming_prefix" {
  description = "The naming prefix for all resources in this example"
  type        = string
  default     = "oaaksdemo"
}
variable "enviroment" {
  description = "The enviroment for all resources in this example"
  type        = string
  default     = "dev"
}
# variable "vnets" {
#   description = "value to be added as vnets, it is a list data type and default value is empty"
#   type        = list(map(any))
# }