#!/bin/bash
# Requires .NET 7.0 SDK: sudo apt-get update && sudo apt-get install -y dotnet-sdk-7.0

source ./utils.sh
source ./utils_azure.sh

# Perform initial checks and setup passing in the config.json file
init "$1"

# Login to Azure
SUBSCRIPTION_ID=$(read_config ".subscription_id")
login_to_azure "$SUBSCRIPTION_ID"

# Read global parameters from the config file
RESOURCE_GROUP=$(read_config ".rg")
LOCATION=$(read_config ".location")
RANDOM_STRING=$(read_config ".random_string")
create_resource_group "$RESOURCE_GROUP" "$LOCATION"

# Check if the storage account already exists; If it does ask user to change
# name in config.json
APP_NAME=$(read_config ".name")
STORAGE_ACCOUNT="${APP_NAME}2store${RANDOM_STRING}" 
STORAGE_ACCOUNT=$(echo $STORAGE_ACCOUNT | sed 's/-//g' | tr '[:upper:]' '[:lower:]') # Storage accounts must be numbers and lower-case letters only.

# Check if storage account exists. If so, ask user to change the name in config.json
if [ "$(az storage account check-name --name "$STORAGE_ACCOUNT" --query nameAvailable)" = false ]; then
    echo "Storage Account $STORAGE_ACCOUNT already exists. The name of this storage account is based on the app name in config.json."
    echo "To fix, choose a unique managed app name ('name') in config.json."
    exit 1
fi

UPN=$(read_config ".user_principal")
create_storage "$SUBSCRIPTION_ID" "$UPN" "$RESOURCE_GROUP" "$STORAGE_ACCOUNT" "$LOCATION"