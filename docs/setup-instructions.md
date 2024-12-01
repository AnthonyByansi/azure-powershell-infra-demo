# **Setup Instructions**

## **Overview**

This project automates the deployment of an end-to-end Azure infrastructure using PowerShell scripts. It creates key resources such as Virtual Machines (VMs), Networking components, Storage accounts, and other Azure services necessary for a typical web application architecture. The scripts are designed to work together to deploy a fully functional infrastructure with most commonly used Azure services.

## **Prerequisites**

Before running the scripts, ensure that your environment is set up properly.

### 1. **Azure Subscription**
   - You must have an active Azure subscription.
   - You can create a free Azure account [here](https://azure.microsoft.com/pricing/purchase-options/azure-account?icid=azurefreeaccount&WT.mc_id=%3Fwt.mc_id%3Dstudentamb_260352).

### 2. **Azure PowerShell Module**
   - Confirm you have the latest version of the Azure PowerShell module installed.
   - Install or update the module by running:
     ```powershell
     Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
     ```

### 3. **Azure CLI (Optional)**
   - If you prefer using Azure CLI for certain tasks, you can install it from [here](https://learn.microsoft.com/cli/azure/install-azure-cli?WT.mc_id=%3Fwt.mc_id%3Dstudentamb_260352).

### 4. **Login to Azure**
   - Use the following command to log into your Azure account:
     ```powershell
     Connect-AzAccount
     ```

### 5. **Resource Group**
   - Ensure that you have a resource group to deploy resources to, or the script will create a new one.
   - To create a new resource group:
     ```powershell
     New-AzResourceGroup -Name "YourResourceGroupName" -Location "EastUS"
     ```

### 6. **Service Principal (Optional for Automation)**
   - If automating or using CI/CD pipelines, set up a service principal for authentication.
   - You can create one using Azure CLI:
     ```bash
     az ad sp create-for-rbac --name "YourServicePrincipalName" --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group}
     ```

---

## **File Structure**

```
/azure-infrastructure-deployment
│
├── scripts
│   ├── 01-create-vnet.ps1
│   ├── 02-create-subnets.ps1
│   ├── 03-deploy-virtual-machines.ps1
│   ├── 04-configure-storage.ps1
│   ├── 05-deploy-load-balancer.ps1
│   ├── 06-setup-azure-monitor.ps1
│   ├── vm-parameters.json
│
├── docs
│   └── setup-instructions.md
│
├── README.md
└── config.json
```

---

## **Step-by-Step Setup Guide**

### 1. **Clone the Repository**
   - Clone or download this repository to your local machine:
     ```bash
     git clone https://github.com/AnthonyByansi/azure-powershell-infra-demo.git
     ```

### 2. **Update Configuration Files**

   - **`vm-parameters.json`**  
     This file contains configuration details for deploying virtual machines. Update the `adminPassword` field to a secure password, and ensure other parameters (such as `resourceGroup`, `location`, and `subnet`) are correctly defined.
     
   - **`config.json`**  
     This file contains global configuration settings such as resource group name and region. Ensure that it aligns with your desired deployment location and resource group.

### 3. **Run the PowerShell Scripts**

   Each script in the `scripts` folder serves a specific purpose in the infrastructure deployment process. Follow the order below:

   1. **Create Virtual Network (VNet) and Subnets**  
      The first step is to deploy the VNet and subnets required for the application.
      ```powershell
      .\scripts\01-create-vnet.ps1 -ResourceGroupName "YourResourceGroup" -Location "EastUS"
      ```

   2. **Create Subnets**  
      Deploy the necessary subnets inside your VNet, ensuring that the web and application tiers are isolated.
      ```powershell
      .\scripts\02-create-subnets.ps1 -ResourceGroupName "YourResourceGroup" -VNetName "YourVNet" -Location "EastUS"
      ```

   3. **Deploy Virtual Machines**  
      Use the `03-deploy-virtual-machines.ps1` script to deploy both the web and application tier VMs. This script automatically configures the VMs and adds them to the load balancer backend pool if applicable.
      ```powershell
      .\scripts\03-deploy-virtual-machines.ps1 -ResourceGroupName "YourResourceGroup" -Location "EastUS" -VNetName "YourVNet" -WebSubnetName "WebSubnet" -AppSubnetName "AppSubnet"
      ```

   4. **Configure Storage Account**  
      The next script will create a storage account and blob container, uploading a sample file for demonstration purposes.
      ```powershell
      .\scripts\04-configure-storage.ps1 -ResourceGroupName "YourResourceGroup" -Location "EastUS" -StorageAccountName "YourStorageAccount" -ContainerName "YourContainer"
      ```

   5. **Deploy Load Balancer**  
      Use this script to create a load balancer and distribute traffic between your web VMs.
      ```powershell
      .\scripts\05-deploy-load-balancer.ps1 -ResourceGroupName "YourResourceGroup" -Location "EastUS" -VNetName "YourVNet" -WebSubnetName "WebSubnet"
      ```

   6. **Set Up Monitoring**  
      Finally, configure Azure Monitor to track the performance and availability of the deployed resources.
      ```powershell
      .\scripts\06-setup-azure-monitor.ps1 -ResourceGroupName "YourResourceGroup" -Location "EastUS"
      ```

### 4. **Verification and Validation**

   - After running the scripts, you can verify the deployment by checking the Azure Portal. Ensure that the following resources were created:
     - Virtual Network and Subnets
     - Virtual Machines
     - Load Balancer
     - Storage Account and Blob Containers
     - Network Security Groups (NSG)
     - Azure Monitor configuration

### 5. **Monitoring and Scaling**
   - Once the infrastructure is deployed, you can monitor the performance using Azure Monitor and adjust resources as necessary, such as scaling the VMs or adjusting load balancer rules.

---

## **Troubleshooting**

1. **Error: Resource Group Not Found**  
   If you encounter an error stating the resource group doesn't exist, ensure the resource group is created before running the scripts.
   ```powershell
   New-AzResourceGroup -Name "YourResourceGroup" -Location "EastUS"
   ```

2. **Insufficient Permissions**  
   If you get permission errors, ensure that your account has sufficient permissions in Azure to create the required resources (e.g., VM creation, load balancer setup).

3. **Timeouts or Quotas**  
   If you encounter timeouts or exceed resource quotas, check your Azure subscription limits or the specific resource quotas for your region.