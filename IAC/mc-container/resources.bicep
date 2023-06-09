// Required parameters
param resourceNameSuffix string
param storageAccountId string

// Optional parameters
param location string = 'australiaeast'
param tags object = {}

// Variables
var storageName = last(split(storageAccountId, '/'))
var storageScope = resourceGroup(split(storageAccountId, '/')[2], split(storageAccountId, '/')[4])

// Existing resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageName
  scope: storageScope
  resource files 'fileServices' existing = {
    name: 'default'
  }
}

// New resources
resource container 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'ci-mc-${resourceNameSuffix}'
  location: location
  tags: tags
  properties: {
    containers: [
      {
        name: 'mc'
        properties: {
          image: 'itzg/minecraft-server'
          resources: {
            requests: {
              cpu: 4
              memoryInGB: 3
            }
          }
          environmentVariables: [
            {
              name: 'EULA'
              value: 'TRUE'
            }
            {
              name: 'MOTD'
              value: 'Isaac test server'
            }
            {
              name: 'OPS'
              value: 'boxhead_crafter'
            }
            {
              name: 'ENABLE_AUTOSTOP'
              value: 'TRUE'
            }
            {
              name: 'AUTOSTOP_TIMEOUT_EST'
              value: '1800'
            }
          ]
          ports: [
            {
              port: 25565
              protocol: 'TCP'
            }
          ]
          livenessProbe: {
            exec: {
              command: [
                'mc-health'
              ]
            }
            failureThreshold: 20
            periodSeconds: 5
            timeoutSeconds: 1
            successThreshold: 1
            initialDelaySeconds: 30
          }
          readinessProbe: {
            exec: {
              command: [
                'mc-health'
              ]
            }
            failureThreshold: 20
            periodSeconds: 5
            timeoutSeconds: 1
            successThreshold: 1
            initialDelaySeconds: 30
          }
          volumeMounts: [
            {
              name: 'data'
              mountPath: '/data'
              readOnly: false
            }
          ]
        }
      }
    ]
    restartPolicy: 'OnFailure'
    sku: 'Standard'
    priority: 'Regular'
    osType: 'Linux'
    ipAddress: {
      ports: [
        {
          port: 25565
          protocol: 'TCP'
        }
      ]
      type: 'Public'
    }
    volumes: [
      {
        name: 'data'
        azureFile: {
          shareName: storage.outputs.shareName
          storageAccountName: storage.name
          readOnly: false
          storageAccountKey: storageAccount.listKeys().keys[0].value
        }
      }
    ]
  }
}

module storage 'storage.bicep' = {
  name: 'storage'
  scope: storageScope
  params: {
    resourceNameSuffix: resourceNameSuffix
    storageAccountName: storageName
  }
}
