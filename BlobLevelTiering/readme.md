### Azure blob level tiering
This code snippet is used to connect to an Azure Storage Account and tier all the blobs to Azure Archive Storage Tier.

You need PowerShell module 4.4.0 or newer in order to be able to tier blobs to archive storage.

```markdown
install-module Azure -requiredVersion 4.4.0
Import-Module Azure
```
    