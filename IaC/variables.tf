variable "arm_client_id" {
  description = "The Client ID (Application ID) of the Azure AD application."
  type        = string
}

variable "arm_client_secret" {
  description = "The Client Secret (Application Password) of the Azure AD application."
  type        = string
  sensitive   = true
}

variable "arm_subscription_id" {
  description = "The Subscription ID of the Azure subscription."
  type        = string
}

variable "arm_tenant_id" {
  description = "The Tenant ID of the Azure Active Directory."
  type        = string
}

## Parameters

variable "project_name" {
  description = "The name of the project, used for naming resources."
  type        = string

}

variable "env_dash_abrev" {
  description = "The suffix with dash to be added to resource names based on the environment."
  type        = string
  default     = ""
}

variable "rg_location" {
  description = "Azure region for resources"
  type        = string

  validation {
    condition = contains([
      "Brazil South",
      "East US 2",
      "Central US"
    ], var.rg_location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "location" {
  description = "Value for Azure Resource Group"
  type        = string

}


## ACA

variable "github_packages_pat" {
  description = "Personal Access Token for GitHub Packages, used as a secret in Container Apps to authenticate with GitHub Container Registry."
  type        = string
  sensitive   = true
}

variable "dockerhub_pat" {
  description = "Personal Access Token for Docker Hub, used as a secret in Container Apps to authenticate with Docker Hub."
  type        = string
  sensitive   = true
}

variable "acr_login_server" {
  description = "The login server URL of the Azure Container Registry (e.g., myregistry.azurecr.io)."
  type        = string
}

variable "dockerhub_username" {
  description = "The username for Docker Hub authentication."
  type        = string
  default     = "felipementel"
}

## GitHub Actions OIDC

variable "github_username" {
  description = "GitHub organization or username (e.g. 'felipementel')."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name (e.g. 'my-repo')."
  type        = string
}
