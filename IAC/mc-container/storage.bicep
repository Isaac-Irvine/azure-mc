// Required
param resourceNameSuffix string
param storageAccountName string

// Existing resources
resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
  resource files 'fileServices' existing = {
    name: 'default'
  }
}

// New resources
resource storageShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: 'fs-mc-${resourceNameSuffix}'
  parent: storage::files
  properties: {
    accessTier: 'TransactionOptimized'
    enabledProtocols: 'SMB'
    shareQuota: 10
  }
}

output shareName string = storageShare.name
