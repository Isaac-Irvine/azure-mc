targetScope = 'subscription'

// Required
param resourceNameSuffix string
param storageAccountName string

// Optional
param location string = 'australiaeast'
param tags object = {}

// New resources
resource group 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-mc-storage-${resourceNameSuffix}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  scope: group
  name: 'resources'
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: tags
  }
}

output storageAccountId string = resources.outputs.storageAccountId
