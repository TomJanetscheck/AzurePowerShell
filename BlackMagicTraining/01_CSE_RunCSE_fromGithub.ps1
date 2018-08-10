<#
    You can use this code snippet without adding the CSE script file to a Storage Account.
    The CSE is run directly from GitHub.
#>

$location = "WestEurope"
$fileUri = "https://raw.githubusercontent.com/azureandbeyond/AzurePS/master/BlackMagicTraining/CustomScriptExtension.ps1"
Set-AzureRmVMCustomScriptExtension -Name '<myCSE>' `
-FileUri $fileUri `
-ResourceGroupName '<myRG>' `
-VMName '<myVM>' `
-Run $fileUri `
-Location $location