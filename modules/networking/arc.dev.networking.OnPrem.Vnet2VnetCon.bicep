//MODULE NETWORKING VPN CONENCTION BICEP- AZURE ARCHITECT PROJECT

//PARAMS
param location string = resourceGroup().location

param networking_OnPrem_conn object = {
  name: 'con-azarc-onprem-con01'
  connectionType: 'Vnet2Vnet'   /*Site-to-Site => IPSec*/
  enableBgp: false
  sharedKey: 'az_305_desingning_solutions2022'

} 

param networking_deploy_OnPrem_VpnGateway bool = true

param networking_OnPrem_localNetworkGateway object = {
  name: 'lgw-azarc-onprem-lgw01'
  localAddressPrefix: '10.0.1.80/29' /*10.0.1.80 - 10.0.1.87 (3 + 5*/
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
param networking_rg_hub_name string = 'rg-azarc-hub01-networking-shared-01'

//RESOURCES
resource res_networking_OnPrem_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' existing = {
  name: networking_OnPrem_vpnGateway.name
}

resource res_networking_Hub01_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' existing = {
  name: networking_vpnGateway.name
  scope: resourceGroup(networking_rg_hub_name)
}

resource res_networking_OnPrem_conn 'Microsoft.Network/connections@2021-02-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_conn.name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking On premise- Simulation'
    'az-aut-delete' : 'true'
  }
  properties: {
    connectionProtocol: 'IKEv2'
    connectionType: networking_OnPrem_conn.connectionType
    virtualNetworkGateway1: {
      id: res_networking_OnPrem_vpnGateway.id
      properties: {
      }
    }
    virtualNetworkGateway2: {
      id: res_networking_Hub01_vpnGateway.id
      properties: {
      }
    }
    enableBgp: networking_OnPrem_conn.enableBgp
    sharedKey: networking_OnPrem_conn.sharedKey
  }
  dependsOn: [
    res_networking_Hub01_vpnGateway
  ]
}

resource res_networking_OnPrem_vpnGateway_pip 'Microsoft.Network/publicIPAddresses@2019-11-01' existing = {
  name: networking_OnPrem_vpnGateway.pipName
}

resource res_networking_OnPrem_localNetworkGateway 'Microsoft.Network/localNetworkGateways@2021-02-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_localNetworkGateway.name
  location: location
  tags: {
    'Env': 'Infrastructure'
    'CostCenter': '00123'
    'az-core-projectcode': 'BicepDeployment- Designing Microsoft Azure Infrastructure Solutions '
    'az-core-purpose': 'Networking On premise- Simulation'
    'az-aut-delete' : 'true'
  }
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        networking_OnPrem_localNetworkGateway.localAddressPrefix
      ]
    }
    /*https://docs.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?tabs=bicep#publicipaddresspropertiesformat*/
    gatewayIpAddress: res_networking_OnPrem_vpnGateway_pip.properties.ipAddress  /*'20.238.39.157'*/
  }
}
