variable "environment" {}

variable "app_name" {}

variable "location" {
    default = "westeurope"
}

variable "mongodb_connection_string" {
  description = "Connection string for MongoDB"
  sensitive   = true
}

variable "service_version" {}