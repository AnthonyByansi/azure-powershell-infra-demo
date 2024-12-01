# =====================================
# Script: 03-deploy-virtual-machines.ps1
# Author: Anthony Byansi
# Date:  2024-12-1
# Purpose: Deploy Azure Virtual Machines with a Load Balancer for the Web Tier.
# =====================================

# Parameters
param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$VNetName,

    [Parameter(Mandatory = $true)]
    [string]$WebSubnetName,

    [Parameter(Mandatory = $true)]
    [string]$AppSubnetName
)

# Ensure Azure PowerShell module is imported
Import-Module Az

# Check if the resource group exists
Write-Output "Checking if resource group '$ResourceGroupName' exists..."
if (-not (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Error "Resource group '$ResourceGroupName' does not exist. Please create it first."
    exit
}

# Set VM common configurations
$vmAdminUser = "azureuser"
$vmAdminPassword = Read-Host -Prompt "Enter the VM administrator password" -AsSecureString
$vmSize = "Standard_B2s"

# Create a Public IP for Load Balancer
Write-Output "Creating Public IP for Load Balancer..."
$publicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name "WebLB-PublicIP" `
    -Sku Standard `
    -AllocationMethod Static

# Create a Load Balancer
Write-Output "Creating Load Balancer..."
$frontendIpConfig = New-AzLoadBalancerFrontendIpConfig -Name "WebLB-Frontend" -PublicIpAddress $publicIp
$backendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "WebLB-BackendPool"
$probe = New-AzLoadBalancerProbeConfig -Name "WebLB-HealthProbe" -Protocol Tcp -Port 80 -IntervalInSeconds 15 -ProbeCount 2
$rule = New-AzLoadBalancerRuleConfig -Name "WebLB-Rule" `
    -FrontendIpConfiguration $frontendIpConfig `
    -BackendAddressPool $backendPool `
    -Probe $probe `
    -Protocol Tcp `
    -FrontendPort 80 `
    -BackendPort 80
$loadBalancer = New-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name "WebLB" `
    -FrontendIpConfiguration $frontendIpConfig `
    -BackendAddressPool $backendPool `
    -Probe $probe `
    -LoadBalancingRule $rule

Write-Output "Load Balancer '$($loadBalancer.Name)' created successfully."

# Deploy Web Tier VMs
Write-Output "Deploying Web Tier VMs..."
for ($i = 1; $i -le 2; $i++) {
    $vmName = "WebVM$i"
    $ipConfig = New-AzNetworkInterfaceIpConfig -Name "$vmName-IPConfig" `
        -SubnetId (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName).Subnets | Where-Object { $_.Name -eq $WebSubnetName }
    $nic = New-AzNetworkInterface -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -Name "$vmName-NIC" `
        -IpConfiguration $ipConfig
    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize | `
        Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object PSCredential ($vmAdminUser, $vmAdminPassword)) | `
        Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" | `
        Add-AzVMNetworkInterface -Id $nic.Id
    New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmConfig
    Write-Output "$vmName deployed and added to the Load Balancer Backend Pool."
}

# Deploy Application Tier VM
Write-Output "Deploying Application Tier VM..."
$appVmName = "AppVM"
$appIpConfig = New-AzNetworkInterfaceIpConfig -Name "$appVmName-IPConfig" `
    -SubnetId (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName).Subnets | Where-Object { $_.Name -eq $AppSubnetName }
$appNic = New-AzNetworkInterface -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name "$appVmName-NIC" `
    -IpConfiguration $appIpConfig
$appVmConfig = New-AzVMConfig -VMName $appVmName -VMSize $vmSize | `
    Set-AzVMOperatingSystem -Windows -ComputerName $appVmName -Credential (New-Object PSCredential ($vmAdminUser, $vmAdminPassword)) | `
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" | `
    Add-AzVMNetworkInterface -Id $appNic.Id
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $appVmConfig
Write-Output "$appVmName deployed successfully."

Write-Output "VM deployment completed successfully!"
