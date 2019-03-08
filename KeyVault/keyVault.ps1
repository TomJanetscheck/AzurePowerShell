# Login to Azure Subscription
  Login-AzRMAccount

# Create Azure KeyVault
  $vaultName = "IamaKeyVault"
  New-AzKeyVault `
    -VaultName $vaultName `
    -ResourceGroupName (New-AzResourceGroup -Name KeyVaultDemo -Location "WestEurope").ResourceGroupName`
    -Location "WestEurope" `
    -EnabledForDeployment `
    -EnabledForTemplateDeployment `
    -EnabledForDiskEncryption `
    -Sku standard

#Create a KeyVault Secret for a local admin password
  $password = read-host -assecurestring
  Set-AzKeyVaultSecret -VaultName $vaultName -Name admin -SecretValue $password

# build credentials with KeyVault Secret
  $LocalAdminUser = "myAdmin"
  $Secret = Get-AzKeyVaultSecret -VaultName $vaultName -Name admin
  $Cred = [PSCredential]::new($LocalAdminUser, $Secret.SecretValue)
