resource "azurerm_resource_group" "rg_aug_curitiba_2026" {
  name     = "rg-${var.project_name}${var.env_dash_abrev}"
  location = var.rg_location
}
