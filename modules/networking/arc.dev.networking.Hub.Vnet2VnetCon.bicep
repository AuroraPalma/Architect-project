//MODULE VPN CONNECTION BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location
param networking_rg_onprem_name string = 'rg-azarc-onprem-networking-01'
param networking_Hub01_conn object = {
  name: 'con-azarc-hub01-con01'
  connectionType: 'Vnet2Vnet'   /*Site-to-Site => IPSec*/
  enableBgp: false
  sharedKey: 'az_305_desingning_solutions2022'

} 

param networking_deploy_Hub01_VpnGateway bool = true

param networking_hub01_localNetworkGateway object = {
  name: 'lgw-azarc-hub01-lgw01'
  localAddressPrefix: '172.16.1.0/26'
}

param networking_vpnGateway object = {
  name: 'vgw-azarc-hub01-vgw01'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '10.0.1.72/29'
  pipName: 'pip-azarc-hub01-vgw01'
}

param networking_OnPrem_vpnGateway object = {
  name: 'vgw-azarc-onprem-vgw01'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '172.16.1.64/29'
  pipName: 'pip-azarc-onprem-vgw01'
}

//RESOURCES
resource res_networking_Hub01_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' existing = {
  name: networking_vpnGateway.name
}

resource res_networking_OnPrem_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' existing = {
  name: networking_OnPrem_vpnGateway.name
  scope: resourceGroup(networking_rg_onprem_name)
}

resource res_networking_OnPrem_conn 'Microsoft.Network/connections@2021-02-01' = if (networking_deploy_Hub01_VpnGateway) {
  name: networking_Hub01_conn.name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Connection Hub-On premise'
    'az-aut-delete' : 'true'
  }
  properties: {
    connectionProtocol: 'IKEv2'
    connectionType: networking_Hub01_conn.connectionType
    virtualNetworkGateway1: {
      id: res_networking_Hub01_vpnGateway.id
      properties: {
      }
    }
    virtualNetworkGateway2: {
      id: res_networking_OnPrem_vpnGateway.id
      properties: {
      }
    }
    enableBgp: networking_Hub01_conn.enableBgp
    sharedKey: networking_Hub01_conn.sharedKey
  }
  dependsOn: [
    res_networking_OnPrem_vpnGateway
  ]
}

resource res_networking_Hub_vpnGateway_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' existing = {
  name: networking_vpnGateway.pipName
}

resource res_networking_Hub01_localNetworkGateway 'Microsoft.Network/localNetworkGateways@2021-02-01' = {
  name: networking_hub01_localNetworkGateway.name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Connection HUb- On premise'
    'az-aut-delete' : 'true'
  }
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        networking_hub01_localNetworkGateway.localAddressPrefix
      ]
    }
    /*https://docs.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?tabs=bicep#publicipaddresspropertiesformat*/
    gatewayIpAddress: res_networking_Hub_vpnGateway_pip.properties.ipAddress  /*''*/
  }
}
