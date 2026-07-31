resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "log-${var.project_name}${var.env_dash_abrev}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.project_name}${var.env_dash_abrev}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
}

resource "azurerm_application_insights_api_key" "read_telemetry" {
  name                    = "tf-appinsights-read-telemetry-api-key"
  application_insights_id = azurerm_application_insights.app_insights.id
  read_permissions        = ["aggregate", "api", "draft", "extendqueries", "search"]
}

resource "azurerm_application_insights_api_key" "write_annotations" {
  name                    = "tf-appinsights-write-annotations-api-key"
  application_insights_id = azurerm_application_insights.app_insights.id
  write_permissions       = ["annotations"]
}

resource "azurerm_application_insights_api_key" "authenticate_sdk_control_channel" {
  name                    = "tf-appinsights-authenticate-sdk-control-channel-api-key"
  application_insights_id = azurerm_application_insights.app_insights.id
  read_permissions        = ["agentconfig"]
}

resource "azurerm_application_insights_api_key" "full_permissions" {
  name                    = "tf-appinsights-full-permissions-api-key"
  application_insights_id = azurerm_application_insights.app_insights.id
  read_permissions        = ["agentconfig", "aggregate", "api", "draft", "extendqueries", "search"]
  write_permissions       = ["annotations"]
}

# # ========================================
# # Web Tests para Static Web Apps
# # ========================================
# resource "azurerm_application_insights_standard_web_test" "static_web_apps" {
#   for_each = {
#     "admin-plataforma" = azurerm_static_web_app.static_web_apps_admin-plataforma.default_host_name
#     "report-portal"    = azurerm_static_web_app.static_web_apps_report-portal.default_host_name
#   }

#   name                    = "wt-static-${each.key}${var.env_dash_abrev}"
#   location                = azurerm_resource_group.rg.location
#   resource_group_name     = azurerm_resource_group.rg.name
#   application_insights_id = azurerm_application_insights.app_insights.id

#   frequency      = 300  # 5 minutos
#   timeout        = 30   # 30 segundos
#   enabled        = true
#   retry_enabled  = true

#   geo_locations = [
#     "latam-br-gru-edge",  # Brazil South
#     "us-fl-mia-edge",     # US East
#     "emea-nl-ams-azr"     # Europe West
#   ]

#   request {
#     url       = "https://${each.value}"
#     http_verb = "GET"
#   }

#   validation_rules {
#     expected_status_code        = 200
#     ssl_check_enabled           = true
#     ssl_cert_remaining_lifetime = 7  # Alerta se o certificado expirar em menos de 7 dias
#   }

#   tags = {
#     environment = var.environment
#     type        = "static-web-app"
#     app         = each.key
#   }

#   depends_on = [
#     azurerm_application_insights.app_insights,
#     azurerm_static_web_app.static_web_apps_admin-plataforma,
#     azurerm_static_web_app.static_web_apps_report-portal
#   ]
# }

# # ========================================
# # Web Tests para Container Apps
# # ========================================
# resource "azurerm_application_insights_standard_web_test" "container_apps" {
#   for_each = azurerm_container_app.container_app

#   name                    = "wt-ca-${each.key}${var.env_dash_abrev}"
#   location                = azurerm_resource_group.rg.location
#   resource_group_name     = azurerm_resource_group.rg.name
#   application_insights_id = azurerm_application_insights.app_insights.id

#   frequency      = 300  # 5 minutos
#   timeout        = 30   # 30 segundos
#   enabled        = true
#   retry_enabled  = true

#   geo_locations = [
#     "latam-br-gru-edge",  # Brazil South
#     "us-fl-mia-edge",     # US East
#     "emea-nl-ams-azr"     # Europe West
#   ]

#   request {
#     url       = "https://${each.value.latest_revision_fqdn}"
#     http_verb = "GET"

#     # Se suas APIs precisam de headers específicos, descomente:
#     # header {
#     #   name  = "Accept"
#     #   value = "application/json"
#     # }
#   }

#   validation_rules {
#     expected_status_code        = 200
#     ssl_check_enabled           = true
#     ssl_cert_remaining_lifetime = 7

#     # Se quiser validar conteúdo da resposta, descomente:
#     # content {
#     #   content_match      = "healthy"
#     #   ignore_case        = true
#     #   pass_if_text_found = true
#     # }
#   }

#   tags = {
#     environment = var.environment
#     type        = "container-app"
#     service     = each.key
#   }

#   depends_on = [
#     azurerm_application_insights.app_insights,
#     azurerm_container_app.container_app
#   ]
# }

# # ========================================
# # Alertas de Disponibilidade
# # ========================================
# resource "azurerm_monitor_metric_alert" "availability_alert" {
#   for_each = merge(
#     { for k, v in azurerm_application_insights_standard_web_test.static_web_apps : "static-${k}" => v.id },
#     { for k, v in azurerm_application_insights_standard_web_test.container_apps : "ca-${k}" => v.id }
#   )

#   name                = "alert-availability-${each.key}${var.env_dash_abrev}"
#   resource_group_name = azurerm_resource_group.rg.name
#   scopes              = [each.value]
#   description         = "Alerta quando ${each.key} tem disponibilidade < 80%"
#   severity            = 2  # Warning
#   frequency           = "PT5M"   # Avalia a cada 5 minutos
#   window_size         = "PT15M"  # Janela de 15 minutos

#   criteria {
#     metric_namespace = "Microsoft.Insights/webtests"
#     metric_name      = "availabilityResults/availabilityPercentage"
#     aggregation      = "Average"
#     operator         = "LessThan"
#     threshold        = 80  # Alerta se disponibilidade < 80%
#   }

#   tags = {
#     environment = var.environment
#     alert_type  = "availability"
#   }

#   depends_on = [
#     azurerm_application_insights_standard_web_test.static_web_apps,
#     azurerm_application_insights_standard_web_test.container_apps
#   ]
# }

# # ========================================
# # Alertas de Tempo de Resposta
# # ========================================
# resource "azurerm_monitor_metric_alert" "response_time_alert" {
#   for_each = merge(
#     { for k, v in azurerm_application_insights_standard_web_test.static_web_apps : "static-${k}" => v.id },
#     { for k, v in azurerm_application_insights_standard_web_test.container_apps : "ca-${k}" => v.id }
#   )

#   name                = "alert-response-time-${each.key}${var.env_dash_abrev}"
#   resource_group_name = azurerm_resource_group.rg.name
#   scopes              = [azurerm_application_insights.app_insights.id, each.value]
#   description         = "Alerta quando ${each.key} tem tempo de resposta > 5 segundos"
#   severity            = 3  # Informational
#   frequency           = "PT5M"
#   window_size         = "PT15M"

#   criteria {
#     metric_namespace = "Microsoft.Insights/webtests"
#     metric_name      = "availabilityResults/duration"
#     aggregation      = "Average"
#     operator         = "GreaterThan"
#     threshold        = 5000  # 5 segundos em milissegundos
#   }

#   tags = {
#     environment = var.environment
#     alert_type  = "performance"
#   }

#   depends_on = [
#     azurerm_resource_group.rg,
#     azurerm_container_app.container_app,
#     azurerm_static_web_app.static_web_apps_admin-plataforma,
#     azurerm_static_web_app.static_web_apps_report-portal,
#     azurerm_application_insights_standard_web_test.static_web_apps,
#     azurerm_application_insights_standard_web_test.container_apps
#   ]
# }
