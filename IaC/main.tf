terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.68.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret
  subscription_id = var.arm_subscription_id
  tenant_id       = var.arm_tenant_id
}

provider "azuread" {
  tenant_id     = var.arm_tenant_id
  client_id     = var.arm_client_id
  client_secret = var.arm_client_secret
}

data "azurerm_client_config" "current" {}

module "resource_group" {
  source = "./modulos/resource_group"

  project_name   = var.project_name
  env_dash_abrev = var.env_dash_abrev
  rg_location    = var.rg_location

}

module "acr" {
  source = "./modulos/acr"

  project_name   = var.project_name
  env_dash_abrev = var.env_dash_abrev
  resource_group = module.resource_group.resource_group_name
  location       = module.resource_group.resource_group_location

  depends_on = [module.resource_group]
}

resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "id-${var.project_name}${var.env_dash_abrev}"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  depends_on = [module.resource_group]
}

resource "azurerm_role_assignment" "aca_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

resource "azurerm_role_assignment" "acr_push_github" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions_sp.object_id

  depends_on = [module.acr]
}

module "logs" {
  source = "./modulos/logs"

  project_name        = var.project_name
  env_dash_abrev      = var.env_dash_abrev
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  env_abrev           = var.env_dash_abrev

  depends_on = [module.resource_group]
}

module "container_apps" {
  source = "./modulos/containers_apps"

  project_name                    = var.project_name
  env_dash_abrev                  = var.env_dash_abrev
  location                        = module.resource_group.resource_group_location
  resource_group_name             = module.resource_group.resource_group_name
  github_packages_pat             = var.github_packages_pat
  dockerhub_pat                   = var.dockerhub_pat
  acr_login_server                = module.acr.acr_login_server
  dockerhub_username              = var.dockerhub_username
  user_assigned_identity_id       = azurerm_user_assigned_identity.aca_identity.id
  log_analytics_workspace_id      = module.logs.log_analytics_workspace_id
  appinsights_connection_string   = module.logs.application_insights_connection_string
  appinsights_instrumentation_key = module.logs.application_insights_instrumentation_key

  depends_on = [
    module.logs,
    azurerm_role_assignment.aca_acr_pull
  ]
}
