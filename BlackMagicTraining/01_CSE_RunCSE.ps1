### Run CSE on VM
Set-AzureRmVMCustomScriptExtension -Name '<myCSE>' `
-ContainerName '<myStorageContainer>' `
-FileName Azure_CustomScriptExtension.ps1 `
-StorageAccountName '<mySA>' `
-ResourceGroupName '<myRG>' `
-VMName '<myVM>' `
-Run Azure_CustomScriptExtension.ps1 `
-Location NorthEurope