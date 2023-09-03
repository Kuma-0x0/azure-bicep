param resourceNameBase string
param databaseName string
param containerName string = 'Items'
param location string = resourceGroup().location

resource account 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: 'cosmos-${toLower(resourceNameBase)}'
  location: location
  properties: {
    enableFreeTier: true
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
      }
    ]
    backupPolicy: {
      type: 'Continuous'
      continuousModeProperties: {
        tier: 'Continuous7Days'
      }
    }
    capacity: {
      totalThroughputLimit: 1000
    }
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: 1000
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/partitionKey'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
      uniqueKeyPolicy: {
        uniqueKeys: []
      }
    }
  }
}

output uri string = account.properties.documentEndpoint

#disable-next-line outputs-should-not-contain-secrets // Use only with resource configuration
output primaryKey string = account.listKeys(account.apiVersion).primaryMasterKey

#disable-next-line outputs-should-not-contain-secrets // Use only with resource configuration
output connectionString string = account.listConnectionStrings(account.apiVersion).connectionStrings[0].connectionString
