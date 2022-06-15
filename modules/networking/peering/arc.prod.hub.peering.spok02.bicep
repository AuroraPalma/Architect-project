//MODULE PEERING AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location
param peering_hub01_to_spok02_name string 
param networking_Spoke02 object
param elz_networking_rg_spk02_name string

//RESOURCES
resource res_networking_Spk02_Vnet 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: networking_Spoke02.name
  scope: resourceGroup(elz_networking_rg_spk02_name)
}

//Peering Hub01 to Spoke01
resource res_peering_Hub01_to_Spk02 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: peering_hub01_to_spok02_name
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: res_networking_Spk02_Vnet.id
    }
  }
}
