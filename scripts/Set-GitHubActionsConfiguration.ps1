[CmdletBinding()]
param(
    [ValidateSet('dev', 'hom')]
    [string]$Environment = 'dev',

    [string]$Repository
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-PlainTextSecret {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt
    )

    $secureValue = Read-Host -Prompt $Prompt -AsSecureString
    $credential = [System.Management.Automation.PSCredential]::new('secret', $secureValue)
    return $credential.GetNetworkCredential().Password
}

function Set-RepositoryVariable {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Value
    )

    gh variable set $Name --env $Environment --repo $Repository --body $Value
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set variable '$Name'."
    }
}

function Set-RepositorySecret {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Value
    )

    $Value | gh secret set $Name --env $Environment --repo $Repository
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set secret '$Name'."
    }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI (gh) is required. Install it from https://cli.github.com/ and authenticate with gh auth login.'
}

gh auth token | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'GitHub CLI is not authenticated. Run gh auth login and try again.'
}

if ([string]::IsNullOrWhiteSpace($Repository)) {
    $Repository = gh repo view --json nameWithOwner --jq '.nameWithOwner'
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($Repository)) {
        throw 'Could not resolve the repository. Pass -Repository owner/repository.'
    }
}

Write-Host "Configuring GitHub environment '$Environment' for '$Repository'."

$githubUsername = Read-Host -Prompt 'GitHub owner/organization'
$storageAccountName = Read-Host -Prompt 'Terraform state storage account name'
$storageContainerName = Read-Host -Prompt 'Terraform state storage container name'
$sonarOrganization = Read-Host -Prompt 'SonarCloud organization'

$githubToken = Get-PlainTextSecret -Prompt 'GitHub token for Terraform'
$sonarToken = Get-PlainTextSecret -Prompt 'SonarCloud token'
$snykApiKey = Get-PlainTextSecret -Prompt 'Snyk API key'
$storageSasToken = Get-PlainTextSecret -Prompt 'Storage SAS token or SAS URL'
$azureClientId = Get-PlainTextSecret -Prompt 'Azure service principal client ID'
$azureClientSecret = Get-PlainTextSecret -Prompt 'Azure service principal client secret'
$azureSubscriptionId = Get-PlainTextSecret -Prompt 'Azure subscription ID'
$azureTenantId = Get-PlainTextSecret -Prompt 'Azure tenant ID'
$otlpHoneycombHeaders = Get-PlainTextSecret -Prompt 'Honeycomb OTLP headers (optional; press Enter to skip)'

$azureCredentials = @{
    clientId       = $azureClientId
    clientSecret   = $azureClientSecret
    subscriptionId = $azureSubscriptionId
    tenantId       = $azureTenantId
} | ConvertTo-Json -Compress

Set-RepositoryVariable -Name 'GITHUB_USERNAME' -Value $githubUsername
Set-RepositoryVariable -Name 'SONAR_ORGANIZATION' -Value $sonarOrganization
Set-RepositoryVariable -Name 'TF_STATE_STORAGE_ACCOUNT' -Value $storageAccountName
Set-RepositoryVariable -Name 'TF_STATE_STORAGE_CONTAINER' -Value $storageContainerName

Set-RepositorySecret -Name 'AZURE_CREDENTIALS' -Value $azureCredentials
Set-RepositorySecret -Name 'AZURE_STORAGE_ACCOUNT_SAS_TOKEN' -Value $storageSasToken
Set-RepositorySecret -Name 'TF_VAR_GITHUB_TOKEN' -Value $githubToken
Set-RepositorySecret -Name 'TF_VAR_SONAR_TOKEN' -Value $sonarToken
Set-RepositorySecret -Name 'TF_VAR_SNYK_API_KEY' -Value $snykApiKey

if (-not [string]::IsNullOrWhiteSpace($otlpHoneycombHeaders)) {
    Set-RepositorySecret -Name 'TF_VAR_OTLP_HONEYCOMB_HEADERS' -Value $otlpHoneycombHeaders
}

Write-Host "GitHub Actions configuration for '$Environment' was updated successfully."
