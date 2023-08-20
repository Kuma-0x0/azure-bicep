param resourceNameCommon string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location

var resourceNameBase = '${resourceNameCommon}-${env}'

module appServicePlan 'app-service-plan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    resourceNameCommon: resourceNameCommon
    env: env
    location: location
  }
}

module insights 'application-insights.bicep' = {
  name: 'insightsModule'
  params: {
    resourceNameCommon: resourceNameCommon
    env: env
    location: location
  }
}

var appServiceName = 'app-${resourceNameBase}'
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insights.outputs.instrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: insights.outputs.connectionString
        }
      ]
    }
  }
  resource appServiceSlot 'slots@2022-09-01' = {
    name: '${appServiceName}-pre'
    location: location
    properties:{
      serverFarmId: appServicePlan.outputs.id
      httpsOnly: true
      siteConfig: {
        appSettings: [
          {
            name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
            value: insights.outputs.instrumentationKey
          }
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: insights.outputs.connectionString
          }
        ]
      }
    }
  }
}

output resourceId string = appService.id
output slotId string = appService::appServiceSlot.id
output location string = appService.location
