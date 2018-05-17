### Run CSE on VM
$locataion = "WestEurope"
$fileUri = "https://raw.githubusercontent.com/azureandbeyond/AzurePS/master/BlackMagicTraining/CustomScriptExtension.ps1"
Set-AzureRmVMCustomScriptExtension -Name '<myCSE>' `
-FileUri $fileUri `
-ResourceGroupName '<myRG>' `
-VMName '<myVM>' `
-Run $fileUri `
-Location $location