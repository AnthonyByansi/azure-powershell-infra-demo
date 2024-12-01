# =====================================
# Script: 02-setup-networking.ps1
# Author: Anthony Byansi
# Date:  2024-12-1
# Purpose: Set up Azure networking (VNet, subnets, NSGs) for the project.
# =====================================

# Parameters
param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$VNetName
)

# Ensure Azure PowerShell module is imported
Import-Module Az

# Check if the resource group exists
Write-Output "Checking if resource group '$ResourceGroupName' exists..."
if (-not (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Error "Resource group '$ResourceGroupName' does not exist. Please create it first."
    exit
}

# Define subnets
$subnetConfig = @(
    @{Name = "WebSubnet"; AddressPrefix = "10.0.1.0/24" },
    @{Name = "AppSubnet"; AddressPrefix = "10.0.2.0/24" },
    @{Name = "DbSubnet"; AddressPrefix = "10.0.3.0/24" }
)

# Create a virtual network
Write-Output "Creating virtual network '$VNetName'..."
$vnet = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $VNetName `
    -AddressPrefix "10.0.0.0/16"

# Add subnets to the virtual network
foreach ($subnet in $subnetConfig) {
    Write-Output "Adding subnet '$($subnet.Name)' with address prefix '$($subnet.AddressPrefix)'..."
    Add-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet `
        -Name $subnet.Name `
        -AddressPrefix $subnet.AddressPrefix
}

# Commit subnet configurations to the virtual network
Set-AzVirtualNetwork -VirtualNetwork $vnet

# Create a Network Security Group (NSG)
$nsgName = "$VNetName-NSG"
Write-Output "Creating Network Security Group '$nsgName'..."
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $nsgName

# Add security rules to the NSG
Write-Output "Adding security rules to NSG '$nsgName'..."
New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" `
    -NetworkSecurityGroup $nsg `
    -Protocol "Tcp" `
    -Direction "Inbound" `
    -SourceAddressPrefix "*" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange 80 `
    -Access "Allow" `
    -Priority 100

New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" `
    -NetworkSecurityGroup $nsg `
    -Protocol "Tcp" `
    -Direction "Inbound" `
    -SourceAddressPrefix "*" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange 3389 `
    -Access "Allow" `
    -Priority 200

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

# Associate NSG with subnets
foreach ($subnet in $subnetConfig) {
    Write-Output "Associating NSG '$nsgName' with subnet '$($subnet.Name)'..."
    Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName | Get-AzVirtualNetworkSubnetConfig -Name $subnet.Name
    Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet `
        -Name $subnet.Name `
        -AddressPrefix $subnet.AddressPrefix `
        -NetworkSecurityGroup $nsg
}

Set-AzVirtualNetwork -VirtualNetwork $vnet

# Output result
Write-Output "Networking setup completed successfully!"
Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName | Format-Table Name, Location, ResourceId -AutoSize
