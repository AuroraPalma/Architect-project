/*Replicar lo del spk01*/
param location string = resourceGroup().location
param networking_Spoke02 object = {
  name: 'vnet-azarc-spk02'
  addressPrefix: '10.2.0.0/22'
  subnetFrontName: 'snet-spk02-front'
  subnetFrontPrefix: '10.2.0.0/25'
  subnetBackName: 'snet-spk02-back'
  subnetBackPrefix: '10.2.0.128/25'

}

resource res_networking_Spk02 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: networking_Spoke02.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networking_Spoke02.addressPrefix
      ]
    }
    subnets: [
      {
        name: networking_Spoke02.subnetFrontName
        properties: {
          addressPrefix: networking_Spoke02.subnetFrontPrefix
        }
      }
      {
        name: networking_Spoke02.subnetBackName
        properties: {
          addressPrefix: networking_Spoke02.subnetBackPrefix
        }
      }
    ]
  }
}

/*Peerings*/
resource res_networking_Hub01_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: 'vnet-azarc-hub01'
  scope: resourceGroup('rg-azarc-hub-networking-01')
}


resource res_peering_Spk02_2_Hub01  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${res_networking_Spk02.name}/per-azarc-hub01-to-spk02'
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

