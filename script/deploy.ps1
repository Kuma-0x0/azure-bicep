# Tenent id
$TENANT=""

# Subscription name or Subscription id
$SUBSCRIPTION=""

# Resource group name
$RESOUCE_GROUP=""

# Bicep file path
$BICEP_PATH=""

# Bicep parameters
$RESOURCE_NAME_COMMON=""
$ENV=""

az login --tenant $TENANT
az account set --subscription $SUBSCRIPTION
az deployment group create --name Example --resource-group $RESOUCE_GROUP --template-file $BICEP_PATH --parameters resourceNameCommon=$RESOURCE_NAME_COMMON env=$ENV
