# Azure-Virtual-Desktops

## Azure Virtual Desktops Bicep Main File

This Bicep main file is used to deploy Azure Virtual Desktops resources.

### Prerequisites

Before deploying the resources using this Bicep main file, ensure you have:

- An Azure subscription
- Permissions to create resources in the target Azure resource group
- Installed the latest version of Azure CLI

### Uploading Configuration Files

Before deploying the host pools, you need to create a `configurations.zip` file containing the configuration files for the host pools. Follow these steps:

1. Clone this repository to your local machine.

2. Open a terminal or command prompt and navigate to the cloned repository.

3. Navigate to the `host-pool` directory:

    ```bash
    cd host-pool
    ```

4. Edit the configuration files for your host pools as necessary.

5. Create a `configurations` directory in the `host-pool` directory, and copy the configuration files into it:

    ```bash
    mkdir configurations
    cp <path_to_config_files> configurations/
    ```

6. Create a `configurations.zip` file containing the `configurations` directory:

    ```bash
    zip -r configurations.zip configurations
    ```

7. Upload the `configurations.zip` file to an Azure Storage account. You can use the Azure Portal, Azure Storage Explorer, Azure CLI, or other tools to upload the file. Note the Storage account name and the container name where you uploaded the file.

### Deploying Resources

To deploy the resources using this Bicep main file, follow these steps:

1. Clone this repository to your local machine.

2. Open a terminal or command prompt and navigate to the cloned repository.

3. Use the Azure CLI to sign in to your Azure account:

    ```bash
    az login
    ```

4. Use the following command to deploy the Bicep template:

    ```bash
    az deployment sub create --location <azure_region> --template-file main.bicep --parameters parameters.json --name <deployment_name> --verbose --parameters storageAccountName=<storage_account_name> containerName=<container_name>
    ```

    Replace `<azure_region>` with the Azure region where you want to deploy the resources, `<deployment_name>` with a name for the deployment, `<storage_account_name>` with the name of the Storage account where you uploaded the `configurations.zip` file, and `<container_name>` with the name of the container where you uploaded the file.

5. Wait for the deployment to complete. You can monitor the deployment status using the Azure CLI:

    ```bash
    az deployment sub show --name <deployment_name> --query "properties.provisioningState"
    ```

6. Once the deployment is complete, verify that the resources are deployed and functioning correctly.

### Cleanup

To remove the resources deployed using this Bicep main file, follow these steps:

1. Use the following command to delete the deployment:

    ```bash
    az deployment sub delete --name <deployment_name>
    ```

2. Wait for the resources to be deleted.

### Conclusion

This Bicep main file provides an easy way to deploy Azure Virtual Desktops resources. By following the steps outlined above, you can quickly and easily deploy and manage your resources in Azure.
