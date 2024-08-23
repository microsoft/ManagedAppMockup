# Utilities to manage Azure assets

# Function to login to Azure and set the right subscription.
# Takes as parameter the subscription id
login_to_azure() {
    local subscription_id=$1
    echo "Logging in to Azure"
    if ! az account get-access-token &> $OUTPUT_DEST; then
        echo "Please login first e.g., az login"
        exit 1
    fi
    echo "Setting Subscription to $subscription_id"
    if ! az account set --subscription "$subscription_id"; then
        echo "Error setting account subscription to $subscription_id"
        exit 1
    fi
}

# Function to create Azure resource group
create_resource_group() {
    local rg_name=$1
    local location=$2
    echo Creating a New Resource Group $rg_name at location $location
    if [ "$(az group exists --name $rg_name)" = false ]; then
        if ! az group create --name "$rg_name" --location "$location" &> $OUTPUT_DEST; then
            echo "Error creating group $rg_name"
            exit 1
        fi
    else
        echo Resource Group $rg_name already exists
    fi
    echo Done Creating Group $rg_name
}

# Function to delete Azure resource group if it exists
delete_resource_group() {
    local rg_name=$1
    echo "Deleting Resource Group $rg_name"
    if [ "$(az group exists --name "$rg_name")" = false ]; then
        echo "Resource Group $rg_name does not exist."
    else
        if ! az group delete --name "$rg_name" --yes &> $OUTPUT_DEST; then
            echo "Error deleting group $rg_name"
            exit 1
        else
            echo "Done Deleting Group $rg_name"
        fi
    fi
}

# Function to create a storage account
create_storage() {
    local subscription_id=$1
    local upn=$2
    local rg_name=$3
    local storage_account_name=$4
    local location=$5

    # Create Azure Storage Account
    echo "Creating Storage for Managed App"
    az storage account create \
        --name "$storage_account_name" \
        --resource-group "$rg_name" \
        --location "$location" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --allow-blob-public-access true &> $OUTPUT_DEST || exit_on_error "Failed to create storage account"

    # Assign Storage Blob Data Contributor role to the storage account
    az role assignment create \
        --role "Storage Blob Data Contributor" \
        --assignee "$upn" \
        --scope "/subscriptions/$subscription_id/resourceGroups/$rg_name/providers/Microsoft.Storage/storageAccounts/$storage_account_name" &> $OUTPUT_DEST || exit_on_error "Failed to assign role to storage account"

    # Create Azure Storage Container
    echo "Creating Storage Container"
    az storage container create \
        --account-name "$storage_account_name" \
        --auth-mode login \
        --name managedappcontainer \
        --fail-on-exist \
        --public-access blob &> $OUTPUT_DEST || exit_on_error "Failed to create storage container"
}

# Function to create an Azure Function
create_func() {
    local rg_name=$1
    local storage_account_name=$2
    local location=$3
    local app_name=$4
    local zip_file=$5

    # Create the function app
    echo "Creating Function App"
    az functionapp create \
        --name "$app_name" \
        --resource-group "$rg_name" \
        --storage-account "$storage_account_name" \
        --consumption-plan-location "$location" \
        --disable-app-insights true \
        --os-type Linux \
        --runtime python \
        --runtime-version 3.8 \
        --functions-version 4 &> $OUTPUT_DEST || exit_on_error "Failed to create function app"
    echo "Function App Created"

    echo "Deploying Function App"
    az functionapp deployment source config-zip \
        --name "$app_name" \
        --resource-group "$rg_name" \
        --src "$zip_file" &> $OUTPUT_DEST || exit_on_error "Failed to deploy function app"
    echo "Function App Deployed"
}

# Function to upload an app zip file and create a url to the file
upload_zip_and_create_blob_url() {
    local rg_name=$1
    local storage_account_name=$2
    local zip_file=$3

    # Get the storage account key
    local stor_key=$(az storage account keys list \
        --account-name "$storage_account_name" \
        --resource-group "$rg_name" \
        --query "[0].value" -o tsv)

    # Upload the zip file
    echo "Uploading Zip file to Azure Storage Blob"
    az storage blob upload \
        --account-name "$storage_account_name" \
        --account-key "$stor_key" \
        --container-name managedappcontainer \
        --name "managed-app.zip" \
        --overwrite \
        --file "$zip_file" &> $OUTPUT_DEST || exit_on_error "Failed to upload zip file $zip_file"
    echo "Upload Complete"

    # Create the blob URL for the managed application package
    blob=$(
        az storage blob url \
            --account-name "$storage_account_name" \
            --account-key "$stor_key" \
            --container-name managedappcontainer \
            --name "managed-app.zip" \
            --output tsv
    )
}

# Function to create a managed app definition
# Assumes $stor_key is defined (i.e., from create_storage_and_upload_zip above)
create_managed_app_definition() {
    local rg_name=$1
    local storage_account_name=$2
    local location=$3
    local app_name=$4
    local upn=$5

    # Get object ID of the user group to use for managing the resources
    local groupid=$(az ad user list --upn $upn --query [].id --output tsv)

    # Next, you need the role definition ID of the Azure built-in role you want to grant access to the user,
    # user group, or application. Typically, you use the Owner or Contributor or Reader role. The following
    # command shows how to get the role definition ID for the Owner role
    local ownerid=$(az role definition list --name Owner --query [].name --output tsv)

    # Create the managed application definition
    echo "Creating Managed App Definition"
    az managedapp definition create \
        --name "${app_name}Def" \
        --location "$location" \
        --resource-group "$rg_name" \
        --lock-level ReadOnly \
        --display-name "${app_name} Managed App Definition" \
        --description "${app_name} Managed App Definition" \
        --authorizations "$groupid:$ownerid" \
        --package-file-uri "$blob" &> $OUTPUT_DEST || exit_on_error "Failed to create managed app definition $app_name"
    echo "Managed App Definition Created"
}

# Function to create a managed app
create_managed_app() {
    local subscription_id=$1
    local rg_name=$2
    local storage_account_name=$3
    local location=$4
    local app_name=$5
    local func_url=$6

    # Get ID of managed app definition
    local managedappdef=$(az managedapp definition show -g "$rg_name" -n "${app_name}Def" --query id --output tsv)

    # Managed application is located in its own auto-created group.
    local rg_name_app="${rg_name}-managedapp"
    local managedapprg=/subscriptions/$subscription_id/resourceGroups/$rg_name_app

    JSON_STRING="{\"func\": {\"value\": \"${func_url}\"}}"

    echo "Creating Managed App $app_name"
    az managedapp create \
        --kind ServiceCatalog \
        --location "$location" \
        --resource-group "$rg_name" \
        --name "$app_name" \
        --parameters "$JSON_STRING" \
        --managed-rg-id "$managedapprg" \
        --managedapp-definition-id "$managedappdef" &> $OUTPUT_DEST || exit_on_error "Failed to create managed app $app_name"
    echo "Managed App $app_name Created"
}