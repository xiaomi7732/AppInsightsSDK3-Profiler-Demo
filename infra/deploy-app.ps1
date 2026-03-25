<#
.SYNOPSIS
    Publishes and deploys the AISDK3 .NET application to an existing Azure Web App.

.PARAMETER ResourceGroupName
    Name of the Azure resource group. Default: app-insights-sdk-3-profiler-demo

.PARAMETER AppName
    Base name used during infra deployment. Default: aisdk3

.EXAMPLE
    .\deploy-app.ps1
    .\deploy-app.ps1 -AppName myapp
#>

param(
    [string]$ResourceGroupName = "app-insights-sdk-3-profiler-demo",
    [string]$AppName = "aisdk3"
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path $PSScriptRoot -Parent
$WebAppName = "app-$AppName"

Write-Host "=== AISDK3 Application Deployment ===" -ForegroundColor Cyan
Write-Host "Resource Group : $ResourceGroupName"
Write-Host "Web App        : $WebAppName"
Write-Host ""

# 1. Publish .NET application (clean output first)
Write-Host "[1/2] Publishing .NET application..." -ForegroundColor Yellow
$publishDir = Join-Path $ProjectDir "publish"
if (Test-Path $publishDir) { Remove-Item $publishDir -Recurse -Force }
dotnet publish "$ProjectDir\AISDK3.csproj" -c Release -o $publishDir --nologo
if ($LASTEXITCODE -ne 0) { throw ".NET publish failed." }
Write-Host "      Build succeeded." -ForegroundColor Green

# 2. Zip deploy to Azure Web App
Write-Host "[2/2] Deploying to Azure Web App..." -ForegroundColor Yellow
$zipPath = Join-Path $ProjectDir "publish.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path "$publishDir\*" -DestinationPath $zipPath

az webapp deploy `
    --resource-group $ResourceGroupName `
    --name $WebAppName `
    --src-path $zipPath `
    --type zip `
    --output none
if ($LASTEXITCODE -ne 0) { throw "App deployment failed." }

$hostName = (az webapp show --resource-group $ResourceGroupName --name $WebAppName --query defaultHostName -o tsv)

Write-Host ""
Write-Host "=== Application Deployed ===" -ForegroundColor Cyan
Write-Host "App URL: https://$hostName" -ForegroundColor Green
