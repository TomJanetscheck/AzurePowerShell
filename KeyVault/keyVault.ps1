# Login to Azure Subscription
  Login-AzAccount

# Create Azure Resource Group
$resourceGroupName = (New-AzResourceGroup -Name KeyVaultDemo -Location "WestEurope").ResourceGroupName

# Create Azure KeyVault
  $vaultName = "IamaKeyVault"
  New-AzKeyVault `
    -VaultName $vaultName `
    -ResourceGroupName $resourceGroupName`
    -Location "WestEurope" `
    -EnabledForDeployment `
    -EnabledForTemplateDeployment `
    -EnabledForDiskEncryption `
    -Sku standard

# Give your user access rights to Azure KeyVault secrets
Set-AzKeyVaultAccessPolicy -VaultName $vaultName `
    -ResourceGroupName $resourceGroupName `
    -UserPrincipalName (Get-AzContext).account.id `
    -PermissionsToSecrets get,set
    
#Create a KeyVault Secret for a local admin password
  $password = read-host -assecurestring
  Set-AzKeyVaultSecret -VaultName $vaultName -Name admin -SecretValue $password

# build credentials with KeyVault Secret
  $LocalAdminUser = "myAdmin"
  $Secret = Get-AzKeyVaultSecret -VaultName $vaultName -Name admin
  $Cred = [PSCredential]::new($LocalAdminUser, $Secret.SecretValue)
