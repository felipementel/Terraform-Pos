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


locals {
  # The GitHub organization enables OIDC subject customization with numeric owner
  # and repository IDs. Entra ID requires the resulting subject to match exactly.
  github_oidc_repository = "repo:${var.github_username}@${var.github_owner_id}/${var.repo_name}@${module.repo.repository_id}"

  # Builds the full OIDC subject string from a short-form context.
  # Supported prefixes:
  #   branch:<name>       → refs/heads/<name>
  #   tag:<name>          → refs/tags/<name>
  #   environment:<name>  → environment:<name>
  #   pull_request        → pull_request
  #   (anything else)     → used as-is (full subject)
  subject_map = {
    for s in var.oidc_subjects : s => (
      startswith(s, "branch:") ? "${local.github_oidc_repository}:ref:refs/heads/${substr(s, 7, -1)}" :
      startswith(s, "tag:") ? "${local.github_oidc_repository}:ref:refs/tags/${substr(s, 4, -1)}" :
      startswith(s, "environment:") ? "${local.github_oidc_repository}:environment:${substr(s, 12, -1)}" :
      s == "pull_request" ? "${local.github_oidc_repository}:pull_request" :
      s
    )
  }
}

# Federated Identity Credentials — one per OIDC subject (branch, tag, environment, PR)
#checkov:skip=CKV_AZURE_249:GitHub Actions OIDC subjects are intentionally hardcoded for repository-scoped branch, tag, environment, and pull request flows and are not exposed as workflow or root variables.
resource "azuread_application_federated_identity_credential" "github_actions_oidc" {
  for_each = local.subject_map

  application_id = azuread_application.github_actions_app.id
  display_name   = "gh-oidc-${replace(each.key, ":", "-")}"
  description    = "GitHub Actions OIDC credential for ${each.key}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = each.value
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
