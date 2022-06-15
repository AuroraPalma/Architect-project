//MODULE PEERING AZURE ARCHITECT PROJECT
//PARAMS
param location string = resourceGroup().location
param networking_Spoke01 object
param elz_networking_rg_spk01_name string
param peering_hub01_to_spk01_name string

//RESOURCES
resource res_networking_Spk01_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Spoke01.name
  scope: resourceGroup(elz_networking_rg_spk01_name)
}

//Peering Hub01 to Spoke01
resource res_peering_Hub01_2_Spk01  'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: peering_hub01_to_spk01_name
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: res_networking_Spk01_Vnet.id
    }
  }
}
