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
  description = "The name of the resource group where the container apps will be deployed."
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

variable "registry_username" {
  description = "The registry username used to pull images"
  type        = string
  default     = "felipementel"
}

variable "user_assigned_identity_id" {
  description = "The client ID of the user assigned identity to be used by Container Apps for pulling images from private registries."
  type        = string
}

variable "acr_login_server" {
  description = "The login server URL of the Azure Container Registry (e.g., myregistry.azurecr.io)."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  type        = string
}

variable "appinsights_connection_string" {
  description = "Application Insights connection string."
  type        = string
  sensitive   = true
}

variable "appinsights_instrumentation_key" {
  description = "Application Insights instrumentation key."
  type        = string
  sensitive   = true
}
