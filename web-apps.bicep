param resourceNameBase string

param location string = resourceGroup().location

module appServicePlan 'app-service-plan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    resourceNameBase: resourceNameBase
    location: location
  }
}

module insights 'application-insights.bicep' = {
  name: 'insightsModule'
  params: {
    resourceNameBase: resourceNameBase
    location: location
  }
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-${resourceNameBase}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
  }
}

resource appServiceSlot 'Microsoft.Web/sites/slots@2022-09-01' = {
  parent: appService
  name: '${appService.name}-pre'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    serverFarmId: appService.properties.serverFarmId
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

output resourceId string = appService.id
output slotId string = appServiceSlot.id
output location string = appService.location
