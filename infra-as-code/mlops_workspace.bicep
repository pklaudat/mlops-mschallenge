targetScope = 'subscription'

param location string = deployment().location

var mIdentityName = 'ml-identity'
var mlWorkspaceName = 'mlops-workspace'
var acrName = 'acrmlopspklaudat'
var storageAccountName = 'samlopsworkspace'
var keyVaultName = 'kv-mlops-workspace'
var appInsightsName = 'appinsights-mlops-workspace'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-mlops-workspace'
  location: location
  tags : {
    department: 'IT'
    project: 'MLOps'
  }
}

module identity 'modules/identity.bicep' = {
  name: 'mlIdentity'
  scope: rg
  params: {
    location: location
    mIdentityName: mIdentityName
    mlWorkspaceName: mlWorkspaceName
    keyVaultName: keyVaultName
    acrName: acrName
  }
}



module privateContainerRegistry 'modules/privateRegistry.bicep' = {
  name: 'privateCotainerRegistry'
  scope: rg
  params: {
    location: location
    identityId: identity.outputs.identityId
    containerRegistryName: acrName
  }
  dependsOn: [
    identity
  ]
}


module mlWorkspace 'modules/mlworkspace.bicep' = {
  name: 'mlWorkspace'
  scope: rg
  params: {
    location: location
    mlWorkspaceName: mlWorkspaceName
    storageAccountName: storageAccountName
    keyVaultName: keyVaultName
    appInsightsName: appInsightsName
    containerRegistryId: privateContainerRegistry.outputs.acrId
    userAssignedId: identity.outputs.identityId
  }
  dependsOn: [
    identity
  ]
}
