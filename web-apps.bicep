param resourceNamePrefix string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location


resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${resourceNamePrefix}-${env}-asp'
  location: location
  properties:{
    reserved: false
  }
  sku:{
    name: 'F1'
    // name: 'S1' スロットを設定するにはStandard以上が必要
  }
}

var appServiceName = '${resourceNamePrefix}-${env}-app'
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
  resource appServiceSlot 'slots@2022-09-01' = {
    name: '${appServiceName}-pre'
    location: location
    properties:{
      serverFarmId: appServicePlan.id
      httpsOnly: true
    }
  }
}
