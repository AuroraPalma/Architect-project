// MODULE BASTION BICEP- AZURE ARCHITECT PROJECT
//Creates an Azure Bastion Subnet and host in the specified virtual network

//PARAMS
@description('The Azure region where the Bastion should be deployed')
param location string = resourceGroup().location
param vnetName string
@description('The address prefix to use for the Bastion subnet')
param addressPrefix string
@description('The name of the Bastion public IP address')
param publicIpName string
@description('The name of the Bastion host')
param bastionHostName string
param networking_Hub01 object

//EXISTING RESOURCE

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
