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
    name:'F1'
  }
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: '${resourceNamePrefix}-${env}-app'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}
