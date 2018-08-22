Set-AzureRmVMExtension `
    -Publisher Microsoft.Azure.ActiveDirectory.LinuxSSH `
    -Name AADLoginForLinux `
    -ResourceGroupName myResourceGroup `
    -VMName myVM `
    -Location WestEurope `
    -ExtensionType AADLoginForLinux `
    -TypeHandlerVersion 1.0