locals {
    backend_image = "backend:${var.service_version}"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.app_name}-${var.environment}-rg"
  location = var.location
}

resource "azurerm_key_vault" "secrets" {
  name                        = "kv-${var.environment}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
}

resource "azurerm_key_vault_secret" "mongodb_connection" {
  name         = "MongoDBConnectionString"
  value        = var.mongodb_connection_string
  key_vault_id = azurerm_key_vault.secrets.id
}

resource "azurerm_user_assigned_identity" "backend" {
  name                = "identity-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_container_registry" "acr" {
  name                = "acr-${var.environment}-registry"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_name}-${var.environment}-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "backend" {
  name                = "${var.app_name}-${var.environment}-backend"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.backend.id]
  }
  site_config {
    application_stack {
      docker_image_name     = "${azurerm_container_registry.acr.login_server}/${local.backend_image}"
    }
    container_registry_use_managed_identity = true
    always_on = true
  }
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    MONGODB_URI                         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.mongodb_connection.id})"
    DOCKER_REGISTRY_SERVER_URL          = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.acr.admin_password
  }
}

resource "azurerm_static_site" "frontend" {
  name                = "${var.app_name}-${var.environment}-frontend"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}
