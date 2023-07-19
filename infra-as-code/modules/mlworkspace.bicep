targetScope = 'resourceGroup'

param location string = resourceGroup().location
param mlWorkspaceName string
param storageAccountName string
param keyVaultName string
param containerRegistryId string
param appInsightsName string
param userAssignedId string


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: {
    department: 'IT'
    project: 'ML'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    enableSoftDelete: false
  }
}

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: (((location == 'eastus2') || (location == 'westcentralus')) ? 'southcentralus' : location)
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource mlWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-06-01-preview' = {
  name: mlWorkspaceName
  location: location
  tags: {
    department: 'IT'
    project: 'ML'
  }
  sku: {
    name: 'Basic'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedId}': {}
    }
  }
  properties: {
    description: 'ML Workspace'
    friendlyName: 'ML Workspace'
    keyVault: keyVault.id
    storageAccount: storageAccount.id
    applicationInsights: applicationInsight.id
    containerRegistry: containerRegistryId
    hbiWorkspace: false
    primaryUserAssignedIdentity: userAssignedId
  }
}
