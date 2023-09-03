param resourceNameBase string
param location string = resourceGroup().location

var resourceName = 'st${toLower(replace(resourceNameBase, '-', ''))}'
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: resourceName
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
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${resourceName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${accountKey}'
