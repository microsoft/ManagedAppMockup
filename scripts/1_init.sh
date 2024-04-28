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
check_storage_account_exists "$RESOURCE_GROUP" "$STORAGE_ACCOUNT"
create_storage "$RESOURCE_GROUP" "$STORAGE_ACCOUNT" "$LOCATION"