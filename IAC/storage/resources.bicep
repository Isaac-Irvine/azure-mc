// Required
param storageAccountName string

// Optional
param location string = 'australiaeast'
param tags object = {}

// New resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  tags: tags
  properties: {
    largeFileSharesState: 'Enabled'
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
      }
    }
  }
  resource fileServices 'fileServices' = {
    name: 'default'
    properties: {
      protocolSettings: {
        smb: {
          authenticationMethods: 'NTLMv2;'
          channelEncryption: 'AES-256-GCM;'
          versions: 'SMB3.0;SMB3.1.1;'
        }
      }
    }
  }
}

output storageAccountId string = storageAccount.id
