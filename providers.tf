terraform {
  /*backend "azurerm" {
    resource_group_name  = "remote-rg-ashish"
    storage_account_name = "strg12212023ash"
    container_name       = "sai-terraform"
    key                  = "terraform.tfstate"
  }*/
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  required_version = ">=1.0.0"
}

provider "azurerm" {
  features {}



}