targetScope = 'resourceGroup'

param keyVaultName string
param mlWorkspaceName string
param mIdentityName string
param acrName string
param location string = resourceGroup().location

var acrPushRoleDefinitionId = '8311e382-0749-4cb8-b61a-304f252e45ec'
var mlDataScientistRoleDefinitionId = 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
var keyVaultReaderRoleDefinitionId = '21090545-7ca7-4776-b22c-e363652d74d2'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: mIdentityName
  location: location
  tags: {
    department: 'IT'
    project: 'ML'
  }
}

resource workspaceRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(mIdentityName, mlWorkspaceName)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', mlDataScientistRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

resource acrPushRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(mIdentityName, acrName)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPushRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(mIdentityName, keyVaultName)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultReaderRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

output identityId string = managedIdentity.id
output principalId string = managedIdentity.properties.principalId
