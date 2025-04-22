output "backend_url" {
  value = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "mongodb_uri" {
  value     = azurerm_key_vault_secret.mongodb_connection.value
  sensitive = true
}