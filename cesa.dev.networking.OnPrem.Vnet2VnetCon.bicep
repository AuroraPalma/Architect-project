/*
para lanzarlo: az account set --subscription "VSES – MPN_02"
*/
param location string = resourceGroup().location

param networking_OnPrem_conn object = {
  name: 'con-cesa-elz01-onprem-con01'
  connectionType: 'Vnet2Vnet'   /*Site-to-Site => IPSec*/
  enableBgp: false
  sharedKey: 'cesa_mola_este_curso_2022_abc'

} 

param networking_deploy_OnPrem_VpnGateway bool = true

/* 'EXISTING' -> We use this kind of reference to access an existing element in the same RG: */
resource res_networking_OnPrem_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' existing = {
  name: 'vgw-cesa-elz01-onprem-vgw01'
}

resource res_networking_OnPrem_localNetworkGateway 'Microsoft.Network/localNetworkGateways@2021-02-01' existing = {
  name: 'lgw-cesa-elz01-onprem-lgw01'
}

resource res_networking_Hub01_vpnGateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' existing = {
  name: 'vgw-cesa-elz01-hub01-vgw01'
  scope: resourceGroup('rg-cesa-elz01-hub01-networking-01')
}

resource res_networking_OnPrem_conn 'Microsoft.Network/connections@2021-02-01' = if (networking_deploy_OnPrem_VpnGateway) {
  name: networking_OnPrem_conn.name
  location: location
  tags: {
    'cor-ctx-environment': 'development'
    'cor-ctx-projectcode': 'Verne Technology - Curso Cloud Expert Solution Architect'
    'cor-ctx-purpose': 'Conexión para enrutar tráfico entre redes (extremos del túnel). El tráfico de estas redes irá por el túnel'
    'cor-aut-delete' : 'true'
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
/*
    localNetworkGateway2: {
      properties: {

      }
    }*/
  }
  dependsOn: [
  ]
}
