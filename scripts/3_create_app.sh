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
MANAGED_APP_PATH=$(read_config ".managed_app_path")
MANAGED_APP_TMP_BIN_ZIP_FILE="/tmp/managed_app.zip"
RANDOM_STRING=$(read_config ".random_string")
STORAGE_ACCOUNT="${APP_NAME}2store${RANDOM_STRING}" 
STORAGE_ACCOUNT=$(echo $STORAGE_ACCOUNT | sed 's/-//g' | tr '[:upper:]' '[:lower:]') # Storage accounts must be numbers and lower-case letters only.

# Create a local managed app zip file, upload it to a storage account, and delete local zip file
# First, we need to update the createUiDefinition.json file with Azure Function URL. This is because the Azure Function URL includes the random string, 
# which is different for each deployment. 
# [TODO]: Is there a better way to do this hack? Ugh!
FUNC_NAME="${APP_NAME}2func${RANDOM_STRING}"
FUNC_URL="https://${FUNC_NAME}.azurewebsites.net/api/"
cp "$MANAGED_APP_PATH/createUiDefinition.json" "$MANAGED_APP_PATH/createUiDefinition.json.bak"
modify_json_in_place "parameters.basics[0].defaultValue" "$FUNC_URL" "$MANAGED_APP_PATH/createUiDefinition.json"
# Next, zip the code
code2zip "$MANAGED_APP_PATH" "$MANAGED_APP_TMP_BIN_ZIP_FILE"
# Undo the modified createUiDefinition.json file
mv "$MANAGED_APP_PATH/createUiDefinition.json.bak" "$MANAGED_APP_PATH/createUiDefinition.json"
upload_zip_and_create_blob_url "$RESOURCE_GROUP" "$STORAGE_ACCOUNT" "$MANAGED_APP_TMP_BIN_ZIP_FILE"
rm -f "$MANAGED_APP_TMP_BIN_ZIP_FILE"

# Create the managed app definition
UPN=$(read_config ".user_principal")
create_managed_app_definition "$RESOURCE_GROUP" "$STORAGE_ACCOUNT" "$LOCATION" "$APP_NAME" "$UPN"

# Create the managed app
FUNC_NAME="${APP_NAME}2func${HASH_SUBSCRIPTION_ID}"
create_managed_app "$SUBSCRIPTION_ID" "$RESOURCE_GROUP" "$STORAGE_ACCOUNT" "$LOCATION" "$APP_NAME" "$FUNC_URL"