<#
.SYNOPSIS
    Deploys the AISDK3 Azure infrastructure (resource group, App Service, monitoring).

.PARAMETER ResourceGroupName
    Name of the Azure resource group. Default: app-insights-sdk-3-profiler-demo

.PARAMETER Location
    Azure region. Default: eastus

.PARAMETER AppName
    Base name for generated resource names. Default: aisdk3

.EXAMPLE
    .\deploy.ps1
    .\deploy.ps1 -Location westus2 -AppName myapp
#>

param(
    [string]$ResourceGroupName = "app-insights-sdk-3-profiler-demo",
    [string]$Location = "eastus",
    [string]$AppName = "aisdk3"
)

$ErrorActionPreference = "Stop"
$InfraDir = $PSScriptRoot

Write-Host "=== AISDK3 Infrastructure Deployment ===" -ForegroundColor Cyan
Write-Host "Resource Group : $ResourceGroupName"
Write-Host "Location       : $Location"
Write-Host "App Name       : $AppName"
Write-Host ""

# 1. Ensure resource group exists
Write-Host "[1/3] Ensuring resource group exists..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location --output none
if ($LASTEXITCODE -ne 0) { throw "Failed to create resource group." }
Write-Host "      Resource group '$ResourceGroupName' ready." -ForegroundColor Green

# 2. Validate deployment with what-if
Write-Host "[2/3] Validating infrastructure (what-if)..." -ForegroundColor Yellow
az deployment group what-if `
    --resource-group $ResourceGroupName `
    --template-file "$InfraDir\main.bicep" `
    --parameters appName=$AppName appServiceSkuName=P1v3 `
    --no-prompt
if ($LASTEXITCODE -ne 0) { throw "What-if validation failed." }

# 3. Deploy infrastructure
Write-Host "[3/3] Deploying infrastructure..." -ForegroundColor Yellow
$deployment = az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file "$InfraDir\main.bicep" `
    --parameters appName=$AppName appServiceSkuName=P1v3 `
    --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw "Infrastructure deployment failed." }

$webAppName = $deployment.properties.outputs.webAppName.value
$hostName = $deployment.properties.outputs.webAppDefaultHostName.value

Write-Host ""
Write-Host "=== Infrastructure Deployed ===" -ForegroundColor Cyan
Write-Host "Web App  : $webAppName" -ForegroundColor Green
Write-Host "Hostname : $hostName" -ForegroundColor Green
Write-Host "Portal   : https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$ResourceGroupName" -ForegroundColor Green
Write-Host ""
Write-Host "Next: run .\deploy-app.ps1 to publish the .NET application." -ForegroundColor Yellow
