resource "azurerm_container_app_environment" "aca_env" {
  name                       = "cae-${var.project_name}${var.env_dash_abrev}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  logs_destination           = "log-analytics"

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "azurerm_container_app" "container_app" {
  name                         = "ca-${var.project_name}${var.env_dash_abrev}"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  # Adicionar identidade gerenciada
  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  secret {
    name  = "ghcr-pat"
    value = var.github_packages_pat
  }

  # 1. GitHub Container Registry
  registry {
    server               = "ghcr.io"
    username             = var.registry_username
    password_secret_name = "ghcr-pat"
  }

  # 2. Azure Container Registry (com identidade gerenciada)
  registry {
    server   = var.acr_login_server
    identity = var.user_assigned_identity_id
  }

  secret {
    name  = "dockerhub-pat"
    value = var.dockerhub_pat
  }

  secret {
    name  = "appinsights-connection-string"
    value = var.appinsights_connection_string
  }

  secret {
    name  = "appinsights-instrumentation-key"
    value = var.appinsights_instrumentation_key
  }

  # 3. Docker Hub (ou outro)
  registry {
    server               = "docker.io"
    username             = var.dockerhub_username
    password_secret_name = "dockerhub-pat"
  }

  template {
    min_replicas = 1
    max_replicas = 5

    # container {
    #   name   = "ca-${var.project_name}${var.env_dash_abrev}"
    #   image  = "acraugcuritibadev.azurecr.io/felipementel/azurefunctions:1.0-acr-build"
    #   cpu    = 0.25
    #   memory = "0.5Gi"

    container {
      name  = "container-${var.project_name}${var.env_dash_abrev}"
      image = "mcr.microsoft.com/k8se/quickstart:latest"
      //image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"


      liveness_probe {
        transport        = "HTTP"
        port             = 80
        path             = "/"
        initial_delay    = 10
        interval_seconds = 10
        timeout          = 5
      }

      readiness_probe {
        transport        = "HTTP"
        port             = 80
        path             = "/"
        initial_delay    = 10
        interval_seconds = 10
        timeout          = 5
      }

      env {
        name        = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "appinsights-connection-string"
      }

      env {
        name        = "APPINSIGHTS_INSTRUMENTATIONKEY"
        secret_name = "appinsights-instrumentation-key"
      }
    }
  }

  ingress {
    external_enabled           = true
    transport                  = "auto"
    target_port                = 80
    allow_insecure_connections = true
    client_certificate_mode    = "ignore"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = {
    environment = var.env_dash_abrev
  }

  depends_on = [
    azurerm_container_app_environment.aca_env
  ]
}
