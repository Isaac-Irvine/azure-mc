targetScope = 'subscription'

// Variables
var resourceNameSuffix = 'isaac-dev-1'
var location = 'australiaeast'
var tags = {}

module storage '../storage/resourceGroup.bicep' = {
  name: 'storage'
  params: {
    resourceNameSuffix: resourceNameSuffix
    storageAccountName: 'isaacmcstoragedev'
    location: location
    tags: tags
  }
}

module server1 '../mc-container/resourceGroup.bicep' = {
  name: 'server1'
  params: {
    resourceNameSuffix: resourceNameSuffix
    storageAccountId: storage.outputs.storageAccountId
    location: location
    tags: tags
  }
}
