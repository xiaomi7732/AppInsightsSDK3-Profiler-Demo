// Availability test module - standard URL ping test from multiple global locations
// Links to Application Insights for alerting and reporting

@description('Azure region for the test resource')
param location string

@description('Base name used to generate resource names')
param appName string

@description('Application Insights resource ID (for portal linking)')
param appInsightsId string

@description('Web App default hostname to test')
param webAppHostName string

resource availabilityTest 'Microsoft.Insights/webtests@2022-06-15' = {
  name: 'avail-${appName}'
  location: location
  kind: 'standard'
  tags: {
    'hidden-link:${appInsightsId}': 'Resource'
  }
  properties: {
    SyntheticMonitorId: 'avail-${appName}'
    Name: '${appName} Availability Test'
    Kind: 'standard'
    Enabled: true
    Frequency: 300
    Timeout: 30
    RetryEnabled: true
    Locations: [
      { Id: 'us-va-ash-azr' }    // East US
      { Id: 'us-ca-sjc-azr' }    // West US
      { Id: 'emea-nl-ams-azr' }  // West Europe
      { Id: 'apac-jp-kaw-edge' } // Japan East
      { Id: 'emea-gb-db3-azr' }  // UK South
    ]
    Request: {
      RequestUrl: 'https://${webAppHostName}'
      HttpVerb: 'GET'
      FollowRedirects: true
      ParseDependentRequests: false
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}
