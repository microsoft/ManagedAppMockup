# Managed App Mockup

## Usage
1. Edit config.json. In particular, make sure to check these variables are set properly:
    * 'rg': name of resource group; if group does not exist, scripts will create it
    * 'subscription_id': id of your Azure subscription
    * 'user_principal': your e-mail linked with your Azure subscription. For me it is: `s*****u@microsoft.com`
    * 'random_string': set it to a unique value, such as the first 8 characters of your user_principal's hash, to avoid conflicts with others' resources.
2. Run scripts one at a time
    * `./0_cleanup.sh ./config.json`
    * `./1_init.sh ./config.json`
    * `./2_create_func.sh ./config.json`
    * `./3_create_app.sh ./config.json`

Note: If an Azure command fails in a script, re-run the script after a few seconds. Sometimes, newly created resources take time to become available, which can cause failures.

## Description
This code creates a basic Azure managed app of the type 'ServiceCatalog' and an Azure function. The managed app consists of a single resource provider that binds a few UI elements of the managed app to API calls to the Auzre function. 

One UI element is a 'Ping Action' button in the managed app Overview section. Another UI element is an entire page (called "EdgeTune Platform") that displays a table. 

When accessing either UI element, the resource provider makes a call to the Azure function that supports two calls: "Ping" and "Table".

The code is structure in three separate folders:

* 'scripts' contains a series of four Bash scripts designed to be run consecutively to create the managed app.

* 'AzureFunction' is a Python implementation of a stateless Azure function that returns a hardcoded JSON blob in a format compliant with a Managed App

* 'ManagedApp' holds three JSON files that define the user interface of the Managed App

### scripts

There are four scripts whose role is to create the managed app in a piecemeal fashion. I have found this approach particularly useful when encountering failures. Upon a failure, I can simply retry the specific script that is failing rather than having to restart the entire pipeline, as is the case with having one single script for everything.

* config.json: Configuration variables used by the scripts. Check if these values are correct. At the very least, set the subscription_id to your subscript and the user_principal to your Azure e-mail account.
    
* 0_cleanup.sh: deletes the resource group (deleting this resource group automatically deletes the managed resource group)

* 1_init.sh: creates the resource group and a storage account

* 2_create_func.sh: deploys the Azure function

* 3_create_app.sh: packages the three JSON files into a ZIP file, it uploads it to the storage account, creates the managed app definition, and, finally, creates the actual managed app.

### AzureFunction

The Azure function is a single Python file that declares two routes, one for Ping and one for Table. They both return hardcoded JSON responses.

### ManagedApp

The managed app is defined by three JSON files:

* createUiDefinition.json: The user interface for input parameters. It controls what the user sees when they install the managed app.

* viewDefinition.json: The user interface for the managed app's resource view. 

* mainTemplate.json: Azure Resource Manager (ARM) template that defines the resources to be deployed for the managed app. It specifies the infrastructure to be deployed when the managed app is installed.

### Configuration
The script can be configured by modifying the variables in ./scripts/config.json.

#### Variables

- `name`: Azure managed app name.
- `func_path`: Path to Azure function code .
- `managed_app_path`: Path to ManagedApp code.
- `rg`: Resource group holding all resources of the managed app. (This is NOT the managed resource group.)
- `location`: Location. All resources are created in this location.
- `subscription_id`: Id of subscription you have access to.
- `user_principal`: User principal under which the managed app definition is created. Can be an Azure Active Directory user, group, or service principal.

## Azure resources

This code creates the following Azure resources:

- 'rg' -- a resource group
    - a managed app
    - a managed app definition managed application definition
    - a service catalog
    - an app service plan (automatically created by Azure)
    - a storage account (unused during steady-state; needed only for code uploads)
    - an Azure function

- 'rg-managedapp' -- a Azure-managed resource group automatically for the managed app
    - a resource provider