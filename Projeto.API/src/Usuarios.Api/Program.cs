using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;
using Usuarios.Adapters.Persistence;
using Usuarios.Adapters.Repositories;
using Usuarios.Api.Endpoints;
using Usuarios.Application.Services;
using Usuarios.Domain.Ports;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddOpenApi();

var connectionString = builder.Configuration.GetConnectionString("UsersDatabase");
if (string.IsNullOrWhiteSpace(connectionString))
{
    builder.Services.AddSingleton<IUserRepository, InMemoryUserRepository>();
    builder.Services.AddSingleton<UserService>();
}
else
{
    builder.Services.AddDbContext<UsersDbContext>(options =>
        options.UseSqlServer(connectionString, sqlOptions => sqlOptions.EnableRetryOnFailure()));
    builder.Services.AddScoped<IUserRepository, SqlUserRepository>();
    builder.Services.AddScoped<UserService>();
}

var app = builder.Build();

var isOpenApiGeneration =
    Assembly.GetEntryAssembly()?.GetName().Name == "GetDocument.Insider";

if (!isOpenApiGeneration)
{
    if (builder.Configuration.GetValue<bool>("Database:ApplyMigrations") &&
        !string.IsNullOrWhiteSpace(connectionString))
    {
        using var scope = app.Services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<UsersDbContext>();
        await dbContext.Database.MigrateAsync();
    }
}

app.MapOpenApi();
app.UseSwagger();
app.UseSwaggerUI();
app.MapScalarApiReference();

app.MapRootEndpoint();
app.MapHealthEndpoints();
app.MapUserEndpoints();

await app.RunAsync();

public partial class Program
{
    protected Program()
    {
    }
}
