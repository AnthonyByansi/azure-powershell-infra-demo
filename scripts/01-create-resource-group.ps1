# =====================================
# Script: 01-create-resource-group.ps1
# Author: Anthony Byansi
# Date:  2024-12-1
# Purpose: Create an Azure resource group for the project.
# =====================================

# Parameters
param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$Location
)

# Ensure Azure PowerShell module is installed
if (-not (Get-Module -Name Az -ListAvailable)) {
    Write-Output "Installing Azure PowerShell module..."
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
}

# Import the Az module
Import-Module Az

# Authenticate to Azure
Write-Output "Authenticating to Azure..."
Connect-AzAccount

# Check if the resource group already exists
Write-Output "Checking if the resource group '$ResourceGroupName' exists..."
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

if ($null -ne $resourceGroup) {
    Write-Output "Resource group '$ResourceGroupName' already exists in '$($resourceGroup.Location)'. Skipping creation."
}
else {
    # Create the resource group
    Write-Output "Creating resource group '$ResourceGroupName' in location '$Location'..."
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag @{Project = "ContosoWebApp"; Environment = "Development" }
    Write-Output "Resource group '$ResourceGroupName' created successfully."
}

# Verify creation
Write-Output "Retrieving details of the created resource group..."
Get-AzResourceGroup -Name $ResourceGroupName | Format-Table Name, Location, ResourceId -AutoSize
