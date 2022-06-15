//MODULE PEERING ARCHITECT PROJECT
//PARAMS
param location string = resourceGroup().location
param networking_Hub01 object
param elz_networking_rg_hub01_name string
param networking_Spoke01 object
param elz_networking_rg_spk01_name string
param peering_spok01_to_hub_name string


//RESOURCES
resource res_networking_Hub01_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Hub01.name
  scope: resourceGroup(elz_networking_rg_hub01_name)
}

resource res_networking_Spk01 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Spoke01.name
  scope:resourceGroup(elz_networking_rg_spk01_name)
}

resource res_peering_Spk01_2_Hub01  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: peering_spok01_to_hub_name
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


