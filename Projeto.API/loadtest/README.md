# Usuarios API Load Tests

Instale o k6 no Windows:

```powershell
winget install k6 --source winget
```

Inicie a API antes do teste. Por padrão, o cenário usa `http://localhost:5266`.

```powershell
dotnet run --project ..\src\Usuarios.Api\Usuarios.Api.csproj
```

Execute o teste com o perfil padrão de carga:

```powershell
k6 run .\src\index.js
```

Para testar a API no Docker Compose:

```powershell
$env:BASE_URL = 'http://localhost:8081'
k6 run .\src\index.js
```

O cenário valida `GET /health/ready` e executa `POST`, `GET`, `PUT` e `DELETE` em `/usuarios`. Cada iteração cria dados exclusivos e remove o usuário ao final.
