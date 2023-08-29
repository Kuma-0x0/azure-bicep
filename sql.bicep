param resourceNameCommon string

@allowed(['dev', 'stg', 'prod'])
param env string

param adminUserName string

@secure()
param adminUserPassword string

@allowed(['Basic', 'Standard'])
param sku string

@description('照合順序')
@allowed([
  'Japanese_CI_AS'
  'Japanese_CI_AS_KS'
  'Japanese_CI_AS_KS_WS'
  'Japanese_CI_AS_WS'
])
param collation string

param location string = resourceGroup().location

var resourceNameBase = '${resourceNameCommon}-${env}'

resource sqlServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: 'sql-${resourceNameBase}'
  location: location
  properties: {
    administratorLogin: adminUserName
    administratorLoginPassword: adminUserPassword
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  parent: sqlServer
  name: 'sqldb-${resourceNameBase}'
  sku: {
    name: sku
    tier: sku 
  }
  location: location
  properties: {
    collation: collation
    requestedBackupStorageRedundancy: 'Local'
  }
}
