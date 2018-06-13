# Login to Azure Subscription
  Login-AzureRMAccount

# Create Azure KeyVault
  $vaultName = "InsiderDevTour2018CGN"
  New-AzureRmKeyVault `
    -VaultName $vaultName `
    -ResourceGroupName (New-AzureRmResourceGroup -Name InsiderDevTour2018 -Location "WestEurope").ResourceGroupName`
    -Location "WestEurope" `
    -EnabledForDeployment `
    -EnabledForTemplateDeployment `
    -EnabledForDiskEncryption `
    -Sku standard

#Create a KeyVault Secret for a local admin password
  $password = read-host -assecurestring
  Set-AzureKeyVaultSecret -VaultName $vaultName -Name admin -SecretValue $password

# build credentials with KeyVault Secret
  $LocalAdminUser = "myAdmin"
  $Secret = Get-AzureKeyVaultSecret -VaultName $vaultName -Name admin
  $Cred = [PSCredential]::new($LocalAdminUser, $Secret.SecretValue)