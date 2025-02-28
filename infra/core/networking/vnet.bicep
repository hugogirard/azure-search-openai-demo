param name string
param location string = resourceGroup().location
param privateEndpointSubnetName string
param privateEndpointNsgName string
param privateEndpointSubnetAddressPrefix string
param appSubnetName string
param appNsgName string
param appSubnetAddressPrefix string
param privateDnsZoneNames array
param vnetAddressPrefix string

param tags object = {}

resource privateEndpointNsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: privateEndpointNsgName
  location: location
  tags: union(tags, { 'azd-service-name': privateEndpointNsgName })
  properties: {
    securityRules: []
  }
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: appNsgName
  location: location
  tags: union(tags, { 'azd-service-name': appNsgName })
  properties: {
    securityRules: []
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: privateEndpointSubnetAddressPrefix
          networkSecurityGroup: privateEndpointNsg.id == ''
            ? null
            : {
                id: privateEndpointNsg.id
              }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetAddressPrefix
          networkSecurityGroup: appNsg.id == ''
            ? null
            : {
                id: appNsg.id
              }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'Microsoft.Web/serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }

  resource privateEndpointSubnet 'subnets' existing = {
    name: privateEndpointSubnetName
  }

  resource functionAppSubnet 'subnets' existing = {
    name: appSubnetName
  }
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [
  for privateDnsZoneName in privateDnsZoneNames: {
    name: '${privateDnsZoneName}/privateDnsZoneLink'
    location: 'global'
    properties: {
      virtualNetwork: {
        id: virtualNetwork.id
      }
      registrationEnabled: false
    }
  }
]

output virtualNetworkId string = virtualNetwork.id
output name string = virtualNetwork.name
output privateEndpointSubnetName string = virtualNetwork::privateEndpointSubnet.name
output privateEndpointSubnetId string = virtualNetwork::privateEndpointSubnet.id
output appSubnetName string = virtualNetwork::functionAppSubnet.name
output appSubnetId string = virtualNetwork::functionAppSubnet.id
output location string = virtualNetwork.location
output resourceGroup string = resourceGroup().name
