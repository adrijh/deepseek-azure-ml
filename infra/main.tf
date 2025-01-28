locals {
  skeleton = "az-euw-syn-deepseek"
  skeleton_norm = "syneuwdeepseek"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name = local.skeleton
  location = "West Europe"
}

resource "azurerm_storage_account" "this" {
  name                     = local.skeleton_norm
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "models" {
  name                  = "models"
  storage_account_id    = azurerm_storage_account.this.id 
  container_access_type = "private"
}


resource "azurerm_application_insights" "this" {
  name                = "${local.skeleton}-insights"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
}

resource "azurerm_key_vault" "this" {
  name                = "${local.skeleton}-kv"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_container_registry" "this" {
  name                = local.skeleton_norm
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_machine_learning_workspace" "this" {
  name                    = "${local.skeleton}-ml-ws"
  location                = azurerm_resource_group.this.location
  resource_group_name     = azurerm_resource_group.this.name
  key_vault_id            = azurerm_key_vault.this.id
  application_insights_id = azurerm_application_insights.this.id
  storage_account_id      = azurerm_storage_account.this.id
  container_registry_id   = azurerm_container_registry.this.id

  identity {
    type = "SystemAssigned"
  }
}
