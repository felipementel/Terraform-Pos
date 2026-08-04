# Usuarios API .NET

Exemplo do mesmo CRUD de usuarios da pasta `python`, agora implementado em .NET 10 com ASP.NET Core Minimal API, Swagger, persistencia em memoria ou SQL Server, testes automatizados e arquitetura Ports and Adapters.

## Tecnologias

- .NET 10
- ASP.NET Core Minimal API
- EF Core com SQL Server/Azure SQL Database
- Swagger UI
- xUnit

## Pre-requisitos

- Windows com PowerShell
- .NET SDK 10 instalado

Para validar a instalacao:

```powershell
dotnet --list-sdks
```

## Arquitetura

Estrutura da solucao:

```text
src/
|-- Usuarios.Api
|-- Usuarios.Application
|-- Usuarios.Domain
`-- Usuarios.Adapters

tests/
`-- Usuarios.Tests
```

Responsabilidades:

- `Usuarios.Domain`: entidade, excecoes e porta de repositorio
- `Usuarios.Application`: servico de aplicacao e comando de entrada
- `Usuarios.Adapters`: implementacao em memoria do repositorio
- `Usuarios.Api`: endpoints Minimal API, Swagger e composicao da aplicacao
- `Usuarios.Tests`: testes de servico e de API

## Estilo da API

A camada HTTP da versao .NET agora usa Minimal API em vez de controllers MVC.

Isso significa que:

- os endpoints sao mapeados diretamente no startup da aplicacao
- o contrato HTTP continua o mesmo da versao anterior
- a estrutura continua separada por camadas, sem misturar regra de negocio com a borda HTTP

Arquivos principais da borda HTTP:

- `src/Usuarios.Api/Program.cs`
- `src/Usuarios.Api/Endpoints/HealthEndpoints.cs`
- `src/Usuarios.Api/Endpoints/UserEndpoints.cs`

## Modelo de dominio

- `id: int`
- `nome: string`
- `dtNascimento: date`
- `status: bool`
- `telefones: string[]`

## Como rodar

Na pasta `dotnet`:

### 1. Restaurar dependencias

```powershell
dotnet restore
```

### 2. Rodar a API

```powershell
dotnet run --project .\src\Usuarios.Api\Usuarios.Api.csproj
```

Por padrao, usando o `launchSettings.json` atual, a API sobe em:

- API: `http://localhost:5266`
- Swagger UI: `http://localhost:5266/swagger`

Se a porta mudar, o `dotnet run` vai mostrar a URL correta no terminal.

### Rodar localmente com Docker Compose e SQL Edge

Crie o arquivo local de ambiente e inicie os containers:

```powershell
Copy-Item .env.example .env
docker compose up --build
```

 A API fica em `http://localhost:8081` e o SQL Edge em `localhost,1433`. O Compose aplica as migrations automaticamente apenas para esse ambiente. Para remover tambem os dados locais do banco:

```powershell
docker compose down --volumes
```

## Persistencia no Azure SQL Database

Sem uma connection string, a API continua usando memoria. Para persistir os dados, configure a connection string fora dos arquivos versionados:

```powershell
dotnet user-secrets set "ConnectionStrings:UsersDatabase" "Server=tcp:SEU-SERVIDOR.database.windows.net,1433;Initial Catalog=usuarios;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Default" --project .\src\Usuarios.Api\Usuarios.Api.csproj
```

Para criar uma nova migration EF Core, use os arquivos de projeto e o nome completo do contexto:

```powershell
$env:ConnectionStrings__UsersDatabase = "Server=localhost,1433;Initial Catalog=users;User ID=sa;Password=SUA_SENHA;Encrypt=False;TrustServerCertificate=True;"
dotnet ef migrations add InitDatabaseAPI `
	--project .\src\Usuarios.Adapters\Usuarios.Adapters.csproj `
	--startup-project .\src\Usuarios.Api\Usuarios.Api.csproj `
	--context Usuarios.Adapters.Persistence.UsersDbContext `
	--output-dir Persistence\Migrations `
	--verbose
```

Para aplicar as migrations existentes ao banco:

```powershell
dotnet ef database update `
	--project .\src\Usuarios.Adapters\Usuarios.Adapters.csproj `
	--startup-project .\src\Usuarios.Api\Usuarios.Api.csproj
```

Em Azure Container Apps, defina `ConnectionStrings__UsersDatabase` como secret ou referencia do Azure Key Vault. Para identidade gerenciada, conceda acesso ao banco para a identidade da aplicacao e mantenha `Authentication=Active Directory Default` na connection string.

### 3. Build de validacao

```powershell
dotnet build .\src\UsuariosApi.slnx
```

## Como testar

```powershell
dotnet test .\src\UsuariosApi.slnx --collect:"XPlat Code Coverage"
```

Para gerar os relatórios Cobertura, HTML, Markdown e SonarQube localmente, instale o ReportGenerator uma vez e execute:

```powershell
dotnet tool install --global dotnet-reportgenerator-globaltool

$reportTitle = "Usuarios API"
$sonarExclusions = ""
$runNumber = "local"
$runId = Get-Date -Format "yyyyMMddHHmmss"

reportgenerator `
	-reports:"**/TestResults/**/coverage.cobertura.xml" `
	-targetdir:"coveragereport" `
	-reportTypes:"Cobertura;Html;MarkdownSummaryGithub;SonarQube" `
	-title:"$reportTitle" `
	-classfilters:"$sonarExclusions" `
	-filefilters:"-**/obj/**" `
	-tag:"${runNumber}_${runId}"
```

Os arquivos são gerados em `coveragereport/`; abra `coveragereport/index.html` para visualizar o relatório HTML.

Resultado esperado no estado atual do projeto:

- testes de servico
- testes de API
- 9 testes passando

## Endpoints

- `GET /health/live`
- `GET /health/ready`
- `POST /usuarios`
- `GET /usuarios`
- `GET /usuarios/{usuarioId}`
- `PUT /usuarios/{usuarioId}`
- `DELETE /usuarios/{usuarioId}`

## Exemplo de payload

```json
{
	"nome": "Aluno",
	"dtNascimento": "1992-03-14",
	"status": true,
	"telefones": [
		"11911112222",
		"1122223333"
	]
}
```

## CI

O workflow fica em `.github/workflows/ci.yml` e executa:

- restore
- build
- testes

## Observacoes

- A persistencia e totalmente em memoria.
- Ao reiniciar a aplicacao, os dados sao perdidos.
- O endpoint `/health/ready` retorna `503` se o servico principal nao estiver registrado.

## Comandos uteis

```powershell
dotnet restore
dotnet build .\src\UsuariosApi.slnx
dotnet test .\src\UsuariosApi.slnx --collect:"XPlat Code Coverage"
dotnet run --project .\src\Usuarios.Api\Usuarios.Api.csproj
```


gh api user --jq .id

gh api repos/felipementel/DevSecOps.Tools --jq .id
