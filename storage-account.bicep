param resourceNameCommon string

@allowed(['dev', 'stg', 'prod'])
param env string

param location string = resourceGroup().location

var storageAccountName = 'st${resourceNameCommon}${env}'
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

var accountKey = storageAccount.listKeys().keys[0].value
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${accountKey}'
