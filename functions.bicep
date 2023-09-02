param resourceNameBase string

@description('小文字のみ使用可能')
param storageAccountName string

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
    storageAccountName: storageAccountName
    location: location
  }
}

var functionsName = 'func-${resourceNameBase}'
resource functions 'Microsoft.Web/sites@2022-09-01' = {
  name: functionsName
  kind: 'functionapp'
  location: location
  properties: {
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: false
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.outputs.connectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageAccount.outputs.connectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
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
  resource functionsSlot 'slots@2022-09-01' = {
    name: '${functionsName}-pre'
    kind: 'functionapp'
    location: location
    properties: {
      serverFarmId: appServicePlan.outputs.id
      httpsOnly: true
      siteConfig: {
        alwaysOn: false
        appSettings: [
          {
            name: 'AzureWebJobsStorage'
            value: storageAccount.outputs.connectionString
          }
          {
            name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
            value: storageAccount.outputs.connectionString
          }
          {
            name: 'FUNCTIONS_EXTENSION_VERSION'
            value: '~4'
          }
          {
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: 'dotnet'
          }
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
