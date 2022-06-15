// MODULE BASTION BICEP- AZURE ARCHITECT PROJECT
//Creates an Azure Bastion Subnet and host in the specified virtual network

//PARAMS
@description('The Azure region where the Bastion should be deployed')
param location string = resourceGroup().location

@description('Virtual network name')
param vnetName string = networking_Hub01.name

@description('The address prefix to use for the Bastion subnet')
param addressPrefix string = '10.0.1.64/29'

@description('The name of the Bastion public IP address')
param publicIpName string = 'pip-hub01-bastion-01'

@description('The name of the Bastion host')
param bastionHostName string = 'bas-azarc-hub01-bastion-shared-01'

param networking_Hub01 object = {
  name: 'vnet-azarc-hub01-01'
  addressPrefix: '10.0.1.0/24'
  subnetTransitName: 'snet-hub01-transit01'
  subnetTransit: '10.0.1.80/29'
}

resource res_networking_Hub01 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Hub01.name
}

// The Bastion Subnet is required to be named 'AzureBastionSubnet'
var subnetName = 'AzureBastionSubnet'

//RESOURCES
resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${vnetName}/${subnetName}'
  properties: {
    addressPrefix: addressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource publicIpAddressForBastion 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: publicIpAddressForBastion.id
          }
        }
      }
    ]
  }
}

//OUTPUT
output bastionId string = bastionHost.id
