#!/bin/bash
# Requires .NET 7.0 SDK: sudo apt-get update && sudo apt-get install -y dotnet-sdk-7.0

source ./utils.sh
source ./utils_azure.sh

# Perform initial checks and setup passing in the config.json file
init "$1"

SUBSCRIPTION_ID=$(read_config ".subscription_id")
RESOURCE_GROUP=$(read_config ".rg")
LOCATION=$(read_config ".location")
APP_NAME=$(read_config ".name")
RANDOM_STRING=$(read_config ".random_string")
STORAGE_ACCOUNT="${APP_NAME}2store${RANDOM_STRING}" 
STORAGE_ACCOUNT=$(echo $STORAGE_ACCOUNT | sed 's/-//g' | tr '[:upper:]' '[:lower:]') # Storage accounts must be numbers and lower-case letters only.
FUNC_NAME="${APP_NAME}2func${RANDOM_STRING}"
FUNC_PATH=$(read_config ".func_path")
FUNC_ZIP_FILE="/tmp/func.zip"

code2zip "$FUNC_PATH" "$FUNC_ZIP_FILE"
create_func "$RESOURCE_GROUP" "$STORAGE_ACCOUNT" "$LOCATION" "$FUNC_NAME" "$FUNC_ZIP_FILE"
rm -f "/tmp/func.zip"

