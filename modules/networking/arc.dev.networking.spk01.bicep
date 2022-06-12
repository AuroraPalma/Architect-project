//MODULE NETWORKING SPOKE 01 BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location

/* /22 = 1000 ips --> from 10.1.0.0 -to- 10.1.3.255 */
param networking_Spoke01 object = {
  name: 'vnet-azarc-spk01'
  addressPrefix: '10.1.0.0/22'
  subnetFrontName: 'snet-spk01-front'
  subnetFrontPrefix: '10.1.0.0/25'
  subnetBackName: 'snet-spk01-back'
  subnetBackPrefix: '10.1.0.128/25'
  subnetMangament: 'snet-spk01-mngnt'
  subnetMangamentPrefix: '10.1.1.0/29'

}

param networking_Hub01 object = {
  name: 'vnet-azarc-hub01'
  addressPrefix: '10.0.1.0/24'
  subnetTransitName: 'snet-hub01-transit'
  subnetTransit: '10.0.1.80/29'
}

param per_spk01_name string = 'per-azarc-hub01-to-spk01'
param networking_rg_hub01_name string = 'rg-azarc-hub-networking-01'
//RESOURCES
resource res_networking_Spk01 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_Spoke01.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networking_Spoke01.addressPrefix
      ]
    }
    subnets: [
      {
        name: networking_Spoke01.subnetMangament
        properties: {
          addressPrefix: networking_Spoke01.subnetMangamentPrefix
        }
      }
      {
        name: networking_Spoke01.subnetFrontName
        properties: {
          addressPrefix: networking_Spoke01.subnetFrontPrefix
        }
      }
      {
        name: networking_Spoke01.subnetBackName
        properties: {
          addressPrefix: networking_Spoke01.subnetBackPrefix
        }
      }
    ]
  }
}

//PEERINGS HUB - SPOKES

resource res_networking_Hub01_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Hub01.name
  scope: resourceGroup(networking_rg_hub01_name)
}

resource res_peering_Spk01_2_Hub01  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${res_networking_Spk01.name}/${per_spk01_name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: res_networking_Hub01_Vnet.id
    }
  }
}


