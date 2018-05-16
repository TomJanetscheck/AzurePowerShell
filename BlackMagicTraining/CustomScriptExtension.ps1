#Get-Disk | Initialize-Disk -PartitionStyle GPT
#$Disks = Get-Disk | where {$_.FriendlyName -like "Msft Virtual Disk"}
$Disks = Get-Disk | where {$_.PartitionStyle -like "Raw"}
$i = 0
$accessPath = @()
$accessPath += 102..121 | foreach {"$([char]$_):\" } ## add drive letters f:\ to y:\ to the array
Foreach ($Disk in $Disks) {
    Initialize-Disk -PartitionStyle GPT
    New-Volume -Disk $Disk -FileSystem NTFS -FriendlyName Data -AccessPath $accessPath[$i]
    $i++
}