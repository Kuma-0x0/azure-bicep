param resourceNameBase string
param location string = resourceGroup().location

module appServicePlan 'app-service-plan.bicep' = {
  name: 'aspModule'
  params: {
    resourceNameBase: resourceNameBase
    location: location
  }
}

module insights 'application-insights.bicep' = {
  name: 'appiModule'
  params: {
    resourceNameBase: resourceNameBase
    location: location
  }
}

module storageAccount 'storage-account.bicep' = {
  name: 'stModule'
  params: {
    resourceNameBase: resourceNameBase
    location: location
  }
}

resource functions 'Microsoft.Web/sites@2022-09-01' = {
  name: 'func-${resourceNameBase}'
  kind: 'functionapp'
  location: location
  properties: {
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: false
    }
  }
}

resource functionsSlot 'Microsoft.Web/sites/slots@2022-09-01' = {
  parent: functions
  name: '${functions.name}-pre'
  kind: 'functionapp'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: functions.properties.serverFarmId
    httpsOnly: functions.properties.httpsOnly
    siteConfig: {
      alwaysOn: functions.properties.siteConfig.alwaysOn
    }
  }
}

resource functionsConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: functions
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: insights.outputs.instrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: insights.outputs.connectionString
    AzureWebJobsStorage: storageAccount.outputs.connectionString
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccount.outputs.connectionString
    WEBSITE_CONTENTSHARE: '${functions.name}-${uniqueString(resourceGroup().id)}'
  }
}

resource functionsSlotConfig 'Microsoft.Web/sites/slots/config@2022-09-01' = {
  parent: functionsSlot
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: insights.outputs.instrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: insights.outputs.connectionString
    AzureWebJobsStorage: storageAccount.outputs.connectionString
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccount.outputs.connectionString
    WEBSITE_CONTENTSHARE: '${functionsSlot.name}-${uniqueString(resourceGroup().id)}'
  }
}

output resourceId string = functions.id
output slotId string = functionsSlot.id
output location string = functions.location
