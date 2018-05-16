### Upload .ps1 script to Azure storage account
$context = New-AzureStorageContext -StorageAccountName "<mySA>" -StorageAccountKey "<mySAKey>"
Set-AzureRmCurrentStorageAccount -Context $Context
New-AzureStorageContainer -name '<myStorageContainer>'
Set-AzureStorageBlobContent -File '<localpath\myFilename.ps1>' -container '<myStorageContainer>'