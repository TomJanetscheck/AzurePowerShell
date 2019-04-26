<#
                                Create Azure VM
---------------------------------------------------------------------------------
         Version 1.0
         2018/11/15 (YMD)
         Customer:  Azure and Beyond
         Thomas Janetscheck - Principal Consultant, Devoteam | Alegri
---------------------------------------------------------------------------------

#>

## Global parameters
        $subscriptionID = 'yourSubscriptionID'
        $location = 'WestEurope'
        $VmRgName = 'activeDirectory'
        $coreRgName = 'yourCoreRGName'
        $vmName = 'yourVM'
        $vmSize = 'Standard_B2s'    # Standard_D2s_v3
        $PublisherName = 'MicrosoftWindowsServer'   # 'MicrosoftSQLServer'
        $Offer = 'WindowsServer'    # 'SQL2017-WS2016'
        $Skus = '2016-Datacenter'   # 'Enterprise'
        $vnetName = 'yourVnet'
        $subnetName = 'yourSubnet'
        $nicName = $vmName + "-nic01"
        $osDiskName = $vmName + "-OsDisk"
        $numberOfDataDisks = 1
        $dataDiskSize = 64 #size in GB
        $localAdminUser = 'adminUserName'
        $keyVaultName = 'yourKeyVault'
        $secretName = 'localAdmin'
        $bootDiagSaName = 'bootDiagSaName'
        $nsgName = $vmName + "-nsg01"
        $publicIpName = $vmname + "-PublicIP" # If you do not need a public IP address for this VM make sure to remove this line!

### Interactively connect to Azure and select the right Azure Subscription
    Login-AzAccount
    Set-AzContext -SubscriptionId $subscriptionID

### Check and/or create VM Resource Group
    $test = Get-AzResourceGroup -Name $VmRgName -ErrorAction SilentlyContinue
    If (!$test) {
        Write-Host "VM Resource Group not found, creating..." -ForegroundColor green
        $rg = New-AzResourceGroup `
            -Name $VmRgName `
            -Location $location
            Write-Host "VM Resource Group created!" -ForegroundColor Green
    }

### Networking
    $securityRule = New-AzNetworkSecurityRuleConfig `
        -Name "AAB_AllowRDPInbound" `
        -Protocol TCP `
        -SourcePortRange "*" `
        -DestinationPortRange 3389 `
        -DestinationAddressPrefix "*" `
        -SourceAddressPrefix (Invoke-RestMethod http://ipinfo.io/json | Select -exp ip) `
        -Direction Inbound `
        -Access Allow `
        -Priority 100

    $nsg = New-AzNetworkSecurityGroup `
        -Name $nsgName `
        -ResourceGroupName $VmRgName `
        -Location $location `
        -SecurityRules $securityRule

    $vnet = Get-AzVirtualNetwork `
        -Name $vnetName `
        -ResourceGroupName $coreRgName

    $subnetId = (Get-AzVirtualNetworkSubnetConfig `
        -name $subnetName `
        -VirtualNetwork $vnet).Id

    If ($publicIpName) {
        $myPublicIp = New-AzPublicIpAddress `
            -Name $PublicIPName `
            -ResourceGroupName $VmRgName `
            -Location $location `
            -AllocationMethod Static
        If ($vmSize -like "Standard_B*" -or $vmSize -eq "Standard_D2s_v3") {
            $myNIC = New-AzNetworkInterface `
                -Name $nicName `
                -ResourceGroupName $VmRgName `
                -Location $location `
                -SubnetId $subnetId `
                -NetworkSecurityGroupId $nsg.Id `
                -PublicIpAddressId $myPublicIp.Id
        }
        Else {
            $myNIC = New-AzNetworkInterface `
                -Name $nicName `
                -ResourceGroupName $VmRgName `
                -Location $location `
                -SubnetId $subnetId `
                -NetworkSecurityGroupId $nsg.Id `
                -PublicIpAddressId $myPublicIp.Id `
                -EnableAcceleratedNetworking
        }
    }
    Else {
        If ($vmSize -like "Standard_B*" -or $vmSize -eq "Standard_D2s_v3") {
            $myNIC = New-AzNetworkInterface `
                -Name $nicName `
                -ResourceGroupName $VmRgName `
                -Location $location `
                -SubnetId $subnetId `
                -NetworkSecurityGroupId $nsg.Id 
        }
        Else {
            $myNIC = New-AzNetworkInterface `
                -Name $nicName `
                -ResourceGroupName $VmRgName `
                -Location $location `
                -SubnetId $subnetId `
                -NetworkSecurityGroupId $nsg.Id `
                -EnableAcceleratedNetworking 
        }
    }

# Get the secret from your Azure Key Vault and create your local admin credentials
    $Secret = Get-AzKeyVaultSecret `
        -VaultName $keyVaultName `
        -Name $secretName
    $Cred = [PSCredential]::new($LocalAdminUser, $Secret.SecretValue)

# Build the VM config
    $myVm = New-AzVMConfig `
        -VMName $vmName `
        -VMSize $vmSize
    $myVM = Set-AzVMOperatingSystem `
        -VM $myVM `
        -Windows `
        -ComputerName $vmName `
        -Credential $cred `
        -ProvisionVMAgent `
        -EnableAutoUpdate
    $myVM = Set-AzVMSourceImage `
        -VM $myVM `
        -PublisherName $PublisherName `
        -Offer $Offer `
        -Skus $Skus `
        -Version "latest"
    $myVM = Add-AzVMNetworkInterface `
        -VM $myVM `
        -Id $myNIC.Id

    # Check and/or create a VM boot diagnostics Storage Account 
    $test2 = Get-AzStorageAccount `
        -ResourceGroupName $coreRgName `
        -StorageAccountName $bootDiagSaName `
        -ErrorAction SilentlyContinue
    If (!$test2){
        $sa = New-AzStorageAccount `
            -ResourceGroupName $coreRgName `
            -Name $bootDiagSaName `
            -SkuName Standard_LRS `
            -Location $location
    }
    $mvVm = Set-AzVMBootDiagnostics `
        -VM $myVm `
        -Enable `
        -ResourceGroupName $coreRgName `
        -StorageAccountName $bootDiagSaName
    $myVM = Set-AzVMOSDisk `
        -VM $myVm `
        -Name $osDiskName `
        -CreateOption fromImage
    # Create Data Disk(s) if $numberOfDataDisks > 0
    If ($numberOfDataDisks -gt 0){
        For ($n = 1; $n -le $numberOfDataDisks; $n++){
                $dataDiskName = $vmName + "-DataDisk0" + $n
                $myVM = Add-AzVMDataDisk `
                    -VM $myVm `
                    -Name $dataDiskName `
                    -CreateOption empty `
                    -DiskSizeInGB $dataDiskSize `
                    -Lun $n `
                    -Caching None
        }
    }

# Create VM
    New-AzVM `
    -ResourceGroupName $VmRgName `
    -Location $location `
    -VM $myVM