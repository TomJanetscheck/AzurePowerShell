# Login to Azure Subscription
Login-AzureRMAccount

# Create Azure KeyVault
New-AzureRmKeyVault -VaultName "MyKeyVault" -ResourceGroupName "MyResourceGroup" -Location "WestEurope" -EnabledForDeployment -Sku standard

#Create a KeyVault Secret for a local admin password
$password = read-host -assecurestring
Set-AzureKeyVaultSecret -VaultName Mykeyvault -Name admin -SecretValue $password

# build credentials with KeyVault Secret
$LocalAdminUser = "myAdmin"
$Secret = Get-AzureKeyVaultSecret -VaultName MyKeyVault -Name admin
$Cred = [PSCredential]::new($LocalAdminUser, $Secret.SecretValue)