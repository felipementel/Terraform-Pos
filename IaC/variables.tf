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

variable "github_username" {
  description = "GitHub username or organization that owns the repository"
  type        = string
  default     = "felipementel"
}

variable "repo_name" {
  description = "The name of the GitHub repository"
  type        = string
}

variable "repo_description" {
  description = "A short description of the repository"
  type        = string
  default     = ""
}

variable "repo_visibility" {
  description = "The visibility of the repository. Can be 'public' or 'private'"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.repo_visibility)
    error_message = "Visibility must be 'public' or 'private'."
  }
}

variable "sonar_token" {
  description = "The SonarCloud admin token for the repository"
  type        = string
}

variable "sonar_project_key" {
  description = "The SonarQube project key for the repository"
  type        = string
}

variable "sonar_project_name" {
  description = "The SonarCloud project display name"
  type        = string
}

variable "snyk_api_key" {
  description = "The Snyk API key for the repository"
  type        = string
}

variable "rg_location" {
  description = "Azure region where the Resource Group will be created (e.g., brazilsouth, eastus)"
  type        = string
}

variable "env_abrev_dash" {
  description = "Optional environment suffix appended to the Resource Group name (e.g., -dev, -prd)"
  type        = string
  default     = ""
}

variable "deploy_target" {
  description = "The target platform for deployment (ACA, AKS, App Service, Azure Functions, Static Web App). Optional for destroy/recreate."
  type        = string
  default     = null

  validation {
    condition     = var.deploy_target == null ? true : contains(["ACA", "AKS", "App Service", "Azure Functions", "Static Web App"], var.deploy_target)
    error_message = "Deploy target must be one of: ACA, AKS, App Service, Azure Functions, Static Web App."
  }
}

variable "sonar_organization" {
  description = "The SonarCloud organization key"
  type        = string
}

variable "container_registry" {
  description = "The container registry domain (e.g., docker.io, ghcr.io, myacr.azurecr.io). Optional for destroy/recreate."
  type        = string
  default     = null

  validation {
    condition     = var.container_registry == null ? true : can(regex("^(docker\\.io|ghcr\\.io|[a-z0-9][a-z0-9-]*\\.azurecr\\.io)$", var.container_registry))
    error_message = "Container registry must be docker.io, ghcr.io, or a valid *.azurecr.io registry name."
  }
}

variable "build_version" {
  description = "Runtime/SDK version used to build the project (e.g., 10 for .NET, 21 for Java, 3.13 for Python, 20 for Node). Optional when running recreate azure-only."
  type        = string
  default     = null
}

variable "framework" {
  description = "Programming language/runtime of the project (e.g., dotnet, java, python, node). Optional when running recreate azure-only."
  type        = string
  default     = null
}

variable "registry_username" {
  description = "Username for GitHub Container Registry (ghcr.io)."
  type        = string
  default     = "felipementel"
}

variable "otlp_honeycomb_headers" {
  description = "Honeycomb OTLP auth header value (x-honeycomb-team={api-key})."
  type        = string
  sensitive   = true
  default     = null
}

variable "container_port" {
  description = "Port the container listens on. Used for ACA ingress targetPort and health probes."
  type        = number
  default     = 8080
}
