### Request ASCJIT Access to RDP (Port 3389) for any VM in any eligible ARM subscription

### Login to your Azure AD Ressource Manager Account
Login-AzureRmAccount
### In case you have several subscriptions select the proper one
Select-AzureRmSubscription (Get-AzureRMSubscription | Out-GridView -Title "Select your Azure Subscription" -PassThru)
### Select the Azure Resource Group and VM
$ResourceGroupName = (Get-AzureRmResourceGroup | Out-GridView -Title "Select your Resource Group" -PassThru).ResourceGroupName
$VMName = (Get-AzureRmVM -ResourceGroupName $ResourceGroupName  | Out-GridView -Title "Select your Virtual Machine" -PassThru).Name
### Enter a time range greater than 6 minutes and request RDP access to the given VM
$minutes = Read-Host "Enter the time range to open port 3389 on VM $VMName [minutes]"
$ip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
Invoke-ASCJITAccess -ResourceGroupName $ResourceGroupName -VM $VMName -Port 3389  -Minutes $minutes -AddressPrefix $ip