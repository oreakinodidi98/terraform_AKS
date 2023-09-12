terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.34.0"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform"
  #   storage_account_name = "terraformstorageaccount"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # } 
    backend "remote" {
    organization = "oreakinodidi"

    workspaces {
      name = "AKS-demo-dev"
    }
}
}
#provider is used to connect to azure
provider "azurerm" {
  features {}
 }
