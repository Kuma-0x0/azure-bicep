param resourceNameBase string

param adminUserName string

@secure()
param adminUserPassword string

@allowed(['Basic', 'Standard'])
param sku string

@description('照合順序')
param collation string = 'Japanese_XJIS_100_CS_AS_KS_WS'

param location string = resourceGroup().location

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

output connectionString string = 'Data Source=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDB.name};User Id=${adminUserName};Password=${adminUserPassword}'
