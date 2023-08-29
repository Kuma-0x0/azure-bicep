param resourceNameCommon string

@allowed(['dev', 'stg', 'prod'])
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
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
  }
}

resource appServiceConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appService
  name: 'appsettings'
  properties: {
      APPINSIGHTS_INSTRUMENTATIONKEY: insights.outputs.instrumentationKey
      APPLICATIONINSIGHTS_CONNECTION_STRING: insights.outputs.connectionString
  }
}

resource appServiceSlot 'Microsoft.Web/sites/slots@2022-09-01' = {
  parent: appService
  name: '${appServiceName}-pre'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
  }
}

output resourceId string = appService.id
output slotId string = appServiceSlot.id
output location string = appService.location
