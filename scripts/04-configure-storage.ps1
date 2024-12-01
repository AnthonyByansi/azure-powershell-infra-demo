# =====================================
# Script: 04-configure-storage.ps1
# Author: Anthony Byansi
# Date:  2024-12-1
# Purpose: Configure Azure Storage Account and Blob Container.
# =====================================

# Parameters
param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$ContainerName
)

# Ensure Azure PowerShell module is imported
Import-Module Az

# Check if the resource group exists
Write-Output "Checking if resource group '$ResourceGroupName' exists..."
if (-not (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Error "Resource group '$ResourceGroupName' does not exist. Please create it first."
    exit
}

# Create the storage account
Write-Output "Creating storage account '$StorageAccountName' in location '$Location'..."
$storageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $StorageAccountName `
    -SkuName Standard_LRS `
    -Kind StorageV2

Write-Output "Storage account '$StorageAccountName' created successfully."

# Retrieve the storage account context
Write-Output "Retrieving storage account context..."
$storageContext = $storageAccount.Context

# Create the blob container
Write-Output "Creating blob container '$ContainerName'..."
New-AzStorageContainer -Name $ContainerName -Context $storageContext -Permission Blob
Write-Output "Blob container '$ContainerName' created successfully."

# Upload a sample file to the blob container
Write-Output "Uploading sample file to blob container..."
$sampleFilePath = "$PSScriptRoot\sample-file.txt"
if (-not (Test-Path -Path $sampleFilePath)) {
    Write-Output "Creating a sample file..."
    "This is a sample file for the Azure blob container." | Out-File -FilePath $sampleFilePath -Encoding UTF8
}
Set-AzStorageBlobContent -File $sampleFilePath -Container $ContainerName -Blob "sample-file.txt" -Context $storageContext
Write-Output "Sample file uploaded to blob container '$ContainerName' as 'sample-file.txt'."

# Output storage account and container details
Write-Output "Storage configuration completed successfully!"
Write-Output "Storage Account Details:"
$storageAccount | Format-Table StorageAccountName, Location, ResourceGroupName -AutoSize
Write-Output "Blob Container URL: https://$($StorageAccountName).blob.core.windows.net/$ContainerName"
