param resourceNameBase string
param location string = resourceGroup().location

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

output id string = appServicePlan.id
