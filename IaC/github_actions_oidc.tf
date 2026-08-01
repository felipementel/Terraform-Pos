# Entra ID Application (App Registration) for GitHub Actions
resource "azuread_application" "github_actions_app" {
  display_name = "github-actions-${var.repo_name}"
  owners       = [data.azurerm_client_config.current.object_id]
}

# Service Principal linked to the Application
resource "azuread_service_principal" "github_actions_sp" {
  client_id                    = azuread_application.github_actions_app.client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

# Contributor role on Resource Group — allows GitHub Actions to deploy resources
resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = module.resource_group.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions_sp.object_id

  depends_on = [module.resource_group]
}

# Federated Identity Credential — allows GitHub Actions to authenticate via OIDC (no secrets needed)
resource "azuread_application_federated_identity_credential" "github_actions_oidc" {
  application_id = azuread_application.github_actions_app.id
  display_name   = "github-actions-pos-graduacao"
  description    = "Allows GitHub Actions to authenticate using OIDC for deploying to Azure Container Apps"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_username}/${var.repo_name}:ref:refs/heads/main"
}

output "github_actions_client_id" {
  description = "Client ID to configure in GitHub Actions secrets (AZURE_CLIENT_ID)"
  value       = azuread_application.github_actions_app.client_id
}

output "github_actions_tenant_id" {
  description = "Tenant ID to configure in GitHub Actions secrets (AZURE_TENANT_ID)"
  value       = data.azurerm_client_config.current.tenant_id
}

output "github_actions_subscription_id" {
  description = "Subscription ID to configure in GitHub Actions secrets (AZURE_SUBSCRIPTION_ID)"
  value       = data.azurerm_client_config.current.subscription_id
}
