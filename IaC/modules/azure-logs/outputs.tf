output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics.id
}

output "application_insights_id" {
  description = "The ID of the Application Insights."
  value       = azurerm_application_insights.app_insights.id
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Application Insights Instrumentation Key"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "full_permissions_api_key" {
  description = "Application Insights API Key"
  value       = azurerm_application_insights_api_key.full_permissions.api_key
}
