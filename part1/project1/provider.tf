terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
    }
  }
}


provider "azurerm" {
  features {}
}
