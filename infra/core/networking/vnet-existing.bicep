// Taken from https://github.com/martins-vds/ai-hub-gateway-solution-accelerator/blob/9dee1a3d16c6809952f521fbf8f348f762b360e3/infra/modules/networking/vnet-existing.bicep
param name string
param subscriptionId string
param resourceGroupName string
param privateEndpointSubnetName string
param appSubnetName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: name
  scope: resourceGroup(subscriptionId, resourceGroupName)
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: privateEndpointSubnetName
  parent: virtualNetwork
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: appSubnetName
  parent: virtualNetwork
}

output virtualNetworkId string = virtualNetwork.id
output name string = virtualNetwork.name
output privateEndpointSubnetName string = privateEndpointSubnet.name
output privateEndpointSubnetId string = '${virtualNetwork.id}/subnets/${privateEndpointSubnetName}'
output appSubnetName string = appSubnet.name
output appSubnetId string = '${virtualNetwork.id}/subnets/${appSubnetName}'
output location string = virtualNetwork.location
output resourceGroup string = resourceGroupName
