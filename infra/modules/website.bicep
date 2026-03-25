// Website module - Linux App Service Plan and .NET Web App deployment
// Configures the web app with Application Insights integration

@description('Azure region for all resources')
param location string

@description('Base name used to generate resource names')
param appName string

@description('App Service Plan SKU name')
param appServiceSkuName string

@description('.NET runtime stack version (e.g., v10.0)')
param dotnetVersion string

@description('Application Insights connection string')
@secure()
param appInsightsConnectionString string

var appServicePlanName = 'plan-${appName}'
var webAppName = 'app-${appName}'

// App Service Plan - Linux SKU
resource appServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true // Required for Linux
  }
  sku: {
    name: appServiceSkuName
  }
}

// Web App - .NET on Linux with Application Insights
resource webApp 'Microsoft.Web/sites@2024-11-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|${dotnetVersion}'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
      ]
    }
  }
}

output webAppName string = webApp.name
output webAppDefaultHostName string = webApp.properties.defaultHostName
output appServicePlanName string = appServicePlan.name
