# ==========================================
# SQL Server Outputs
# ==========================================
output "sqlserver_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
  sensitive   = false
}

output "sqlserver_admin_username" {
  description = "The administrator username for SQL Server"
  value       = azurerm_mssql_server.sql.administrator_login
  sensitive   = false
}

output "sqlserver_admin_password" {
  description = "The administrator password for SQL Server"
  value       = azurerm_mssql_server.sql.administrator_login_password
  sensitive   = true
}

output "sqlserver_id" {
  description = "The resource ID of the SQL Server"
  value       = azurerm_mssql_server.sql.id
  sensitive   = false
}

output "sqlserver_databases" {
  description = "Map of SQL databases created"
  value = {
    sql-db-import = azurerm_mssql_database.sqbdb_import.name
    sql-db-report = azurerm_mssql_database.sqbdb_report.name
    sql-db-portal = azurerm_mssql_database.sqbdb_portal.name
  }
  sensitive = false
}

# ==========================================
# Outputs formatados para Key Vault
# ==========================================
output "database_vars" {
  description = "Database non-secret configuration values"
  value = {
    # PostgreSQL
    "POSTGRES_HOST" = azurerm_postgresql_flexible_server.psqls.fqdn
    "POSTGRES_PORT" = "5432"
    "POSTGRES_USER" = azurerm_postgresql_flexible_server.psqls.administrator_login

    "POSTGRES_DB_POLYGON" = azurerm_postgresql_flexible_server_database.psql_polygon.name

    "POSTGRES_POOL_SIZE"    = "5"
    "POSTGRES_MAX_OVERFLOW" = "10"
    "POSTGRES_POOL_TIMEOUT" = "30"

    # SQL Server
    "SQLSERVER_HOST" = azurerm_mssql_server.sql.fully_qualified_domain_name
    "SQLSERVER_PORT" = "1433"
    "SQLSERVER_USER" = azurerm_mssql_server.sql.administrator_login

    "SQLSERVER_DB_PORTAL" = azurerm_mssql_database.sqbdb_portal.name
  }
  sensitive = false
}
