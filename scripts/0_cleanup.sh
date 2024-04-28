#!/bin/bash
# Requires .NET 7.0 SDK: sudo apt-get update && sudo apt-get install -y dotnet-sdk-7.0

source ./utils.sh
source ./utils_azure.sh

# Perform initial checks and setup passing in the config.json file
init "$1"

# Login to Azure
SUBSCRIPTION_ID=$(read_config ".subscription_id")
login_to_azure "$SUBSCRIPTION_ID"

# Delete resource group
RESOURCE_GROUP=$(read_config ".rg")
delete_resource_group $RESOURCE_GROUP