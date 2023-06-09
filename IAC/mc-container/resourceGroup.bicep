targetScope = 'subscription'

// Required
param resourceNameSuffix string
param storageAccountId string

// Optional
param location string = 'australiaeast'
param tags object = {}

// New resources
resource group 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-mc-${resourceNameSuffix}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  scope: group
  name: 'resources'
  params: {
    resourceNameSuffix: resourceNameSuffix
    storageAccountId: storageAccountId
    location: location
    tags: tags
  }
}
