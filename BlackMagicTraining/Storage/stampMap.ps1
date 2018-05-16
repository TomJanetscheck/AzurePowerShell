# Create Stamp Map
$storageAccount = @(Get-AzureStorageAccount | where {$_.StorageAccountName -like $baseName + "*"})
Foreach ($account in $storageAccount) {
    $storageAccountName = $account.storageaccountname
    $endpoint = $storageAccountName + '.blob.core.windows.net'
    $dnslookup = [System.Net.Dns]::GetHostAddresses($endpoint)
    $IPAddress = $dnslookup.IpAddressToString
    Write-Host $StorageAccountname, $IPAddress
}