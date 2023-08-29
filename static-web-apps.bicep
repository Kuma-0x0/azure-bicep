param resourceNameCommon string

@allowed(['dev', 'stg', 'prod'])
param env string

@allowed(['Free', 'Standard'])
param sku string = 'Standard'

@allowed([
  'WestUS2'
  'CentralUS'
  'EastUS2'
  'WestEurope'
  'EastAsia'
])
param location string = 'EastUS2'

var resourceNameBase = '${resourceNameCommon}-${env}'

resource swa 'Microsoft.Web/staticSites@2022-09-01' = {
  name: 'swa-${resourceNameBase}'
  location: location
  sku: {
    name: sku
    tier: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    repositoryUrl: 'https://github.com/Kuma-0x0/web-api'
    branch: 'main'
    provider: 'GitHub'
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

// skuをStandardに設定するとWebAppsを設定可能----------
module app 'web-apps.bicep' = {
  name: 'appModule'
  params: {
    resourceNameCommon: resourceNameCommon
    env: env
  }
}

resource staticSites_gaotigaht_name_backend1 'Microsoft.Web/staticSites/linkedBackends@2022-09-01' = {
  parent: swa
  name: 'backend1'
  properties: {
    backendResourceId: app.outputs.slotId // リンクするリソースにスロットがある場合スロットのリソースIDを設定する
    region: app.outputs.location
  }
}
// ---------------------------------------------------
