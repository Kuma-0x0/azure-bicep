param resourceNameCommon string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location

var resourceNameBase = '${resourceNameCommon}-${env}'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${resourceNameBase}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

output connectionString string = applicationInsights.properties.ConnectionString
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
