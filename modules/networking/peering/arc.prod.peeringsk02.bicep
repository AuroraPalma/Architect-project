//MODULE PEERING AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location
param peering_spok02_to_hub_name string 
param networking_Spoke02 object
param elz_networking_rg_spk02_name string
param networking_Hub01 object
param elz_networking_rg_hub01_name string

resource res_networking_Hub01_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Hub01.name
  scope: resourceGroup(elz_networking_rg_hub01_name)
}

//RESOURCES
resource res_networking_Spk02 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Spoke02.name
  scope:resourceGroup(elz_networking_rg_spk02_name)
}

//Peering Spoke02 to Hub01
resource res_peering_Spk02_2_Hub01  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: peering_spok02_to_hub_name
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: res_networking_Hub01_Vnet.id
    }
  }
}
