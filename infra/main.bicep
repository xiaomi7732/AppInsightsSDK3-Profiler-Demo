// Main Bicep template - orchestrates website infrastructure and .NET app deployment
// Deploys: Log Analytics + App Insights (monitoring), App Service Plan + Web App (compute),
//          and a standard availability test for the endpoint

targetScope = 'resourceGroup'

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Base name used to generate resource names')
@minLength(3)
@maxLength(20)
param appName string

@description('App Service Plan SKU')
@allowed(['B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1v3', 'P2v3', 'P3v3'])
param appServiceSkuName string = 'B1'

@description('Log Analytics workspace retention in days')
@minValue(30)
@maxValue(730)
param logRetentionDays int = 30

@description('.NET runtime stack version')
param dotnetVersion string = 'v10.0'

// 1. Deploy monitoring infrastructure (Log Analytics + Application Insights)
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-deployment'
  params: {
    location: location
    appName: appName
    logRetentionDays: logRetentionDays
  }
}

// 2. Deploy website infrastructure and .NET application
module website 'modules/website.bicep' = {
  name: 'website-deployment'
  params: {
    location: location
    appName: appName
    appServiceSkuName: appServiceSkuName
    dotnetVersion: dotnetVersion
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
  }
}

// 3. Standard availability test - pings the web app from multiple global locations
module availabilityTest 'modules/availability-test.bicep' = {
  name: 'availability-test-deployment'
  params: {
    location: location
    appName: appName
    appInsightsId: monitoring.outputs.appInsightsId
    webAppHostName: website.outputs.webAppDefaultHostName
  }
}

// Outputs for CI/CD and reference
output webAppName string = website.outputs.webAppName
output webAppDefaultHostName string = website.outputs.webAppDefaultHostName
output appInsightsName string = monitoring.outputs.appInsightsName
output logAnalyticsWorkspaceId string = monitoring.outputs.logAnalyticsWorkspaceId
