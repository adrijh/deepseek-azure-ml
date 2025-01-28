terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "az-euw-syn-pract-cloud-baseline-rg01-pro"
    storage_account_name = "azeuwsynbasstategsa01pro"
    container_name       = "az-euw-syn-pract-cloud-tfstate-container01-pro"
    key                  = "deepseek-azure.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "b9e89e50-b116-4ee6-8b5a-eb2e0b5a3ee2"

  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

