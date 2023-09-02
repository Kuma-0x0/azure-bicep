# Tenent id
$TENANT=""

# Subscription name or Subscription id
$SUBSCRIPTION=""

# Resource group name
$RESOUCE_GROUP=""

# Bicep file path
$BICEP_PATH=".\functions.bicep"

# Bicep parameters
$RESOURCE_NAME_BASE=""
$STORAGE_ACCOUNT_NAME=""

az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION
az deployment group create --name Example --resource-group $RESOUCE_GROUP --template-file $BICEP_PATH --parameters resourceNameBase=$RESOURCE_NAME_BASE storageAccountName=$STORAGE_ACCOUNT_NAME
