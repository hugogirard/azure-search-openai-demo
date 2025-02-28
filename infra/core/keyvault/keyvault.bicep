metadata description = 'Creates an Azure KeyVault.'
param location string = resourceGroup().location
param tags object = {}


@allowed([ 'Enabled', 'Disabled' ])
param publicNetworkAccess string = 'Enabled'
param softDelete bool = false
param purgeProtection bool = false

param name string
param skuName string = 'standard'
param tenantId string = subscription().tenantId
param serverAppSecretName string
@secure()
param serverAppSecretValue string
param clientAppSecretName string
@secure()
param clientAppSecretValue string
param managedIdentity bool

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: skuName
    }
    publicNetworkAccess: publicNetworkAccess
    enablePurgeProtection: purgeProtection
    enableSoftDelete: softDelete
    enableRbacAuthorization: true
    tenantId: tenantId    
  }
  identity: {
    type: managedIdentity ? 'SystemAssigned' : 'None'
  }  
  tags: tags
  
  resource serverAppSecret 'secrets' = {
    name: serverAppSecretName
    properties: {
      attributes: {
        enabled: true
      }
      value: serverAppSecretValue
    }
  }

  resource clientAppSecret 'secrets' = {
    name: clientAppSecretName
    properties: {
      attributes: {
        enabled: true
      }
      value: clientAppSecretValue
    }

    }  
}

output keyVaultId string = keyVault.id
output name string = keyVault.name
output identityPrincipalId string = managedIdentity ? keyVault.identity.principalId : ''
output serverAppSecretUri string = keyVault::serverAppSecret.properties.secretUri
output clientAppSecretUri string = keyVault::clientAppSecret.properties.secretUri
