# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment

data "github_user" "current" {
  username = "felipementel"
}

resource "github_repository_environment" "environment_development" {
  environment = "development"
  repository  = var.repository_name
}

resource "github_repository_environment" "environment_staging" {
  environment = "staging"
  repository  = var.repository_name
}

resource "github_repository_environment" "environment_production" {
  environment = "production"
  repository  = var.repository_name
}
