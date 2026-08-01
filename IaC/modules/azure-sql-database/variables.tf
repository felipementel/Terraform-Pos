variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string

  validation {
    condition = contains([
      "brazilsouth"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "environment" {
  description = "The environment tag for resources."
  type        = string
}

variable "env_abrev" {
  description = "The suffix to be added to resource names based on the environment."
  type        = string
  default     = ""
}

variable "env_dash_abrev" {
  description = "The suffix with dash to be added to resource names based on the environment."
  type        = string
  default     = ""
}

# Key Vault
variable "key_vault_secrets" {
  description = "Segredos a serem armazenados no Key Vault"
  type        = map(string)
  default     = {}
}

# SQL Server
variable "client_public_ips" {
  description = "IP from client"
  type        = map(string)
  default     = {}
}

# PostgreSQL Flexible Server
variable "postgres_sku_name" {
  description = "The SKU name for the PostgreSQL Flexible Server."
  type        = string
}

variable "postgres_storage_mb" {
  description = "The storage size in MB for the PostgreSQL Flexible Server."
  type        = number
}

variable "postgres_storage_tier" {
  description = "The storage tier for the PostgreSQL Flexible Server."
  type        = string
}

# SQL Database
variable "sqbdb_import_max_size_gb" {
  description = "The maximum size in GB for the SQL Database used for data import."
  type        = number
}

variable "sqbdb_import_sku_name" {
  description = "The SKU name for the SQL Database used for data import."
  type        = string
}

variable "sqbdb_portal_max_size_gb" {
  description = "The maximum size in GB for the SQL Database used for the portal."
  type        = number
}

variable "sqbdb_portal_sku_name" {
  description = "The SKU name for the SQL Database used for the portal."
  type        = string
}

variable "sqbdb_report_max_size_gb" {
  description = "The maximum size in GB for the SQL Database used for reporting."
  type        = number
}

variable "sqbdb_report_sku_name" {
  description = "The SKU name for the SQL Database used for reporting."
  type        = string
}

variable "sqbdb_dataprocessor_max_size_gb" {
  description = "The maximum size in GB for the SQL Database used for data processing."
  type        = number
}

variable "sqbdb_dataprocessor_sku_name" {
  description = "The SKU name for the SQL Database used for data processing."
  type        = string
}

variable "sqbdb_abvoting_max_size_gb" {
  description = "The maximum size in GB for the SQL Database used for AB Voting."
  type        = number
}

variable "sqbdb_abvoting_sku_name" {
  description = "The SKU name for the SQL Database used for AB Voting."
  type        = string
}
