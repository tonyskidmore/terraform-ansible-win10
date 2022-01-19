# Azure rm provider
provider "azurerm" {
  features {}
}

# Terraform version, state backend and provider version
terraform {
  required_version = "~> 1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.89.0"
    }
  }
}