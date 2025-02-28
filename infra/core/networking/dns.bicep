// Taken from https://github.com/martins-vds/ai-hub-gateway-solution-accelerator/blob/9dee1a3d16c6809952f521fbf8f348f762b360e3/infra/modules/networking/dns.bicep

param name string
param tags object = {}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
  tags: union(tags, { 'azd-service-name': name })
}

output privateDnsZoneName string = privateDnsZone.name
