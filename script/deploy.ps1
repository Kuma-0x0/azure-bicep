# Tenent id
$TENANT=""

# Subscription name or Subscription id
$SUBSCRIPTION=""

# Resource group name
$RESOUCE_GROUP=""

# Bicep file path
$BICEP_PATH=""

# Bicep parameters
$RESOURCE_NAME_BASE=""

az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION
az deployment group create --name Example --resource-group $RESOUCE_GROUP --template-file $BICEP_PATH --parameters resourceNameBase=$RESOURCE_NAME_BASE
