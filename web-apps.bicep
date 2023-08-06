param resourceNameCommon string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location

var resourceNameBase = '${resourceNameCommon}-${env}'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${resourceNameBase}'
  location: location
  properties:{
    reserved: false // windowsはfalse、Linuxはtrueに設定する
  }
  sku:{
    // name: 'F1'
    name: 'S1' // スロットを設定するにはStandard以上が必要
  }
}

var appServiceName = 'app-${resourceNameBase}'
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
  }
  resource appServiceSlot 'slots@2022-09-01' = {
    name: '${appServiceName}-pre'
    location: location
    properties:{
      serverFarmId: appServicePlan.id
      httpsOnly: true
      siteConfig: {
        appSettings: [
          {
            name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
            value: applicationInsights.properties.InstrumentationKey
          }
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: applicationInsights.properties.ConnectionString
          }
        ]
      }
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${resourceNameBase}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
